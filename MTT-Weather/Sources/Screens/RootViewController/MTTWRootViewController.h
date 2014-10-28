//
//  MTTWRootViewController.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NSManagedObjectID;
@class MTTWRegion;

@interface MTTWRootViewController : UIViewController

@property (nonatomic, strong) MTTWRegion *region;
@property (nonatomic, strong) NSManagedObjectID *regionID;

@end

