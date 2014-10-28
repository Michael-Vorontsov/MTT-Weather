//
//  MTTWRegionTableViewCell.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/28/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTTWIconImageView;

@interface MTTWRegionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MTTWIconImageView *iconImageView;

@end
