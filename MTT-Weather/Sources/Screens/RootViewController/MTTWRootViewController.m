//
//  MTTWRootViewController.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWRootViewController.h"
#import "MTTWDetailsViewController.h"

@interface MTTWRootViewController ()
@property (weak, nonatomic) IBOutlet UIView *detailsViewContainer;
@property (weak, nonatomic) MTTWDetailsViewController *detailsViewController;
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
    [self detailsViewController];
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


@end
