//
//  MTTWRegionListViewController.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/27/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWRegionListViewController.h"

#import "MTTWRegion.h"
#import "MTTWWeatherCondition.h"
#import "MTTWDataController.h"

#import "MTTWRegionTableViewCell.h"
#import "MTTWRegionHeaderTableViewCell.h"

#import "MTTWIconImageView.h"

#import <CoreData/CoreData.h>

@interface MTTWRegionListViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic, readonly) NSManagedObjectContext *context;

@property (strong, nonatomic) NSFetchedResultsController *resultsController;

@end

NSString *const kMTTWRegionCellReuseID = @"RegionCell";
NSString *const kMTTWRegionHeaderCellReuseID = @"RegionHeaderCell";

@implementation MTTWRegionListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([MTTWRegionTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kMTTWRegionCellReuseID];
    UINib *headerCellNib = [UINib nibWithNibName:NSStringFromClass([MTTWRegionHeaderTableViewCell class]) bundle:nil];
    [self.tableView registerNib:headerCellNib forCellReuseIdentifier:kMTTWRegionHeaderCellReuseID];
}

- (NSManagedObjectContext *)context
{
    return [[MTTWDataController sharedController] mainContext];
}

- (NSFetchedResultsController *)resultsController
{
    if (nil == _resultsController)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMTTWRegionEntityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
            managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;

        NSError *error = nil;
        [_resultsController performFetch:&error];
        NSAssert(nil == error, nil);
    }
    return _resultsController;
}


#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.resultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTTWRegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMTTWRegionCellReuseID
        forIndexPath:indexPath];

    MTTWRegion *region = [self.resultsController objectAtIndexPath:indexPath];

    cell.titleLabel.text = region.name;
    [cell.iconImageView loadImageFromRemotePath:region.currectCondition.weatherIconPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *cell = [tableView dequeueReusableCellWithIdentifier:kMTTWRegionHeaderCellReuseID];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MTTWRegionListViewDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(controller:didSelectRegion:)])
    {
        [delegate controller:self didSelectRegion:[self.resultsController objectAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle && [self.resultsController.fetchedObjects count] > 1)
    {
        if ([tableView.indexPathForSelectedRow isEqual:indexPath])
        {
            NSInteger newIndex = (indexPath.row > 0) ? indexPath.row - 1 : 1;
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:indexPath.section];
            [tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }

        MTTWRegion *regionToRemove = [self.resultsController objectAtIndexPath:indexPath];
        [self.context deleteObject:regionToRemove];
        [MTTWDataController saveChangesInContext:self.context recursive:YES];

    }
}

#pragma mark NSFetchedResultsController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}


@end
