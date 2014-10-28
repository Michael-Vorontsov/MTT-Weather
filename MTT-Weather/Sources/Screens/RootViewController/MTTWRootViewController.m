//
//  MTTWRootViewController.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWRootViewController.h"
#import "MTTWDetailsViewController.h"
#import "MTTWRegion.h"
#import "MTTWDailyForecast.h"
#import "MTTWWeatherCondition.h"
#import "MTTWForecastSyncOperation.h"
#import "MTTWForecastTableViewCell.h"
#import "MTTWDataController.h"

#import "MTTWRegionListViewController.h"

@interface MTTWRootViewController () <UITableViewDataSource,NSFetchedResultsControllerDelegate, MTTWRegionListViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *detailsViewContainer;
@property (weak, nonatomic) MTTWDetailsViewController *detailsViewController;

@property (weak, nonatomic) MTTWRegionListViewController *regionListViewController;
@property (weak, nonatomic) IBOutlet UIView *regionsListContainer;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UITableView *forecastsTableView;

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

const NSTimeInterval kMTTWBackgroundDuration = 20.0;

@implementation MTTWRootViewController
{
    NSDateFormatter *_dateFormatter;
}

NSString *const kMTTWForecastCellReuseID = @"ForecastCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.forecastsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MTTWForecastTableViewCell class]) bundle:nil]
      forCellReuseIdentifier:kMTTWForecastCellReuseID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.detailsViewController.needUpdateUI = YES;
    self.regionListViewController.delegate = self;

    NSArray *images =
    @[
      [UIImage imageNamed:@"Autumn0.jpg"],
      [UIImage imageNamed:@"Autumn1.jpg"],
      [UIImage imageNamed:@"Autumn2.jpg"],
      [UIImage imageNamed:@"Autumn3.jpg"],
    ];

    self.backgroundView.image = [UIImage animatedImageWithImages:images duration:kMTTWBackgroundDuration];
    [self sync];
}


#pragma mark - Lazy

- (MTTWDetailsViewController *)detailsViewController
{
    if (nil == _detailsViewController)
    {
        MTTWDetailsViewController *detailsViewController = [MTTWDetailsViewController new];

        [self addChildViewController:detailsViewController];

        [self.detailsViewContainer addSubview:detailsViewController.view];
        detailsViewController.view.frame = self.detailsViewContainer.bounds;
        detailsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _detailsViewController = detailsViewController;

    }
    return _detailsViewController;
}

- (MTTWRegionListViewController *)regionListViewController
{
    if (nil == _regionListViewController)
    {
        MTTWRegionListViewController *viewController = [MTTWRegionListViewController new];

        [self addChildViewController:viewController];

        [self.regionsListContainer addSubview:viewController.view];
        viewController.view.frame = self.regionsListContainer.bounds;
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _regionListViewController = viewController;

    }
    return _regionListViewController;
}

- (NSFetchedResultsController *)resultsController
{
    if (nil == _resultsController && nil != self.region)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMTTWDailyForecastEntityName];
        request.predicate = [NSPredicate predicateWithFormat:@"region == %@", self.region];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];


        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:
            [[MTTWDataController sharedController] syncContext] sectionNameKeyPath:nil cacheName:nil];

        _resultsController.delegate = self;
        NSError *error = nil;
        [_resultsController performFetch:&error];
        NSAssert(nil == error, nil);
    }

    return _resultsController;;
}

#pragma mark - 
- (NSOperationQueue *)operationQueue
{
    if (nil == _operationQueue)
    {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}

- (void)sync
{
    NSString *regionName = (nil == self.region) ? @"Kiev" : self.region.name;
    [self syncRegionWithName:regionName];
}

- (void)syncRegionWithName:(NSString *)regionName
{
    [self.operationQueue cancelAllOperations];
    MTTWForecastSyncOperation *operation = [MTTWForecastSyncOperation syncOperationForRegionName:regionName];
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:
    ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:
         ^{
             self.regionID = operation.result;
             self.detailsViewController.needUpdateUI = YES;
         }];
    }];

    [completionOperation addDependency:operation];
    
    [self.operationQueue addOperation:operation];
    [self.operationQueue addOperation:completionOperation];
}

- (void)setRegionID:(NSManagedObjectID *)regionID
{

    self.region = (nil == regionID) ? nil :
        (MTTWRegion *)[[[MTTWDataController sharedController] mainContext] objectWithID:regionID];
}

- (NSManagedObjectID *)regionID
{
    return self.region.objectID;
}

- (void)setRegion:(MTTWRegion *)region
{
    if (_region != region)
    {
        _region = region;
        self.detailsViewController.region = region;
        self.resultsController = nil;
        [self.forecastsTableView reloadData];
    }
}

- (NSDateFormatter *)dateFormatter
{
    if (nil == _dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"dd.MMM";
    }
    return _dateFormatter;
}

#pragma mark - UITbaleViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.resultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTTWForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMTTWForecastCellReuseID forIndexPath:indexPath];
    MTTWDailyForecast *forecast = [self.resultsController objectAtIndexPath:indexPath];
    cell.dateLabel.text = [[self dateFormatter] stringFromDate:forecast.date];
    cell.maxTempLabel.text = [@(forecast.maxTemp) stringValue];
    cell.minTempLabel.text = [@(forecast.minTemp) stringValue];
    return cell;

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.forecastsTableView reloadData];
}

#pragma mark - Action

- (IBAction)addNewRegion:(id)sender
{
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.hidden = YES;
    self.searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchString.length > 0)
    {
        [self syncRegionWithName:searchString];
    }
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.searchBar.hidden = YES;
}

#pragma mark - MTTWRegionListViewDelegate

- (void)controller:(MTTWRegionListViewController *)controller didSelectRegion:(MTTWRegion *)region;
{
    self.region = region;
    [self sync];
}

@end
