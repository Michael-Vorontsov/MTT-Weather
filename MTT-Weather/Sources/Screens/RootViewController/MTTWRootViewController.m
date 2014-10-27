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

@interface MTTWRootViewController ()
@property (weak, nonatomic) IBOutlet UIView *detailsViewContainer;
@property (weak, nonatomic) MTTWDetailsViewController *detailsViewController;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation MTTWRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.detailsViewController.needUpdateUI = YES;
    [self sync];
}


#pragma mark - SubControllers Lazy

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
    NSString *regionName = (nil == self.region) ? @"London" : self.region.name;
    MTTWForecastSyncOperation *operation = [MTTWForecastSyncOperation syncOperationForRegionName:regionName];
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:
                                        ^{
                                            [[NSOperationQueue mainQueue] addOperationWithBlock:
                                             ^{
                                                 self.region = operation.result;
                                                 self.detailsViewController.needUpdateUI = YES;
                                             }];
                                        }];
    
    [completionOperation addDependency:operation];
    
    [self.operationQueue addOperation:operation];
    [self.operationQueue addOperation:completionOperation];
}

- (void)setRegion:(MTTWRegion *)region
{
    if (_region != region)
    {
        _region = region;
        self.detailsViewController.region = region;
    }
}

@end
