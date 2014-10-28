//
//  MTTWForecastTableViewCell.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/27/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTTWForecastTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;

@end
