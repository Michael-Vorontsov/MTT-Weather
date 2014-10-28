//
//  MTTWRegionListViewController.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/27/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTTWRegionListViewController;
@class MTTWRegion;

@protocol MTTWRegionListViewDelegate <NSObject>

@optional

- (void)controller:(MTTWRegionListViewController *)controller didSelectRegion:(MTTWRegion *)region;

@end

@interface MTTWRegionListViewController : UIViewController

@property (nonatomic, weak) id<MTTWRegionListViewDelegate> delegate;

@end
