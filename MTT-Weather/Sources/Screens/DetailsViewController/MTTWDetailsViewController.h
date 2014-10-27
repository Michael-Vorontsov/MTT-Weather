//
//  MTTWDetailsViewController.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTTWRegion;

@interface MTTWDetailsViewController : UIViewController

@property (nonatomic, strong) MTTWRegion *region;

@property (nonatomic, getter = isNeedUpdateUI) BOOL needUpdateUI;

@end
