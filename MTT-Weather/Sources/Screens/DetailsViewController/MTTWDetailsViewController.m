//
//  MTTWDetailsViewController.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWDetailsViewController.h"

#import "MTTWWeatherCondition.h"
#import "MTTWRegion.h"
#import "MTTWForecastSyncOperation.h"

#import "MTTWIconImageView.h"

@interface MTTWDetailsViewController ()

@property (weak, nonatomic) IBOutlet MTTWIconImageView *weathrIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *windDirectionIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *regionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTemparatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTemparatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatheDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *temperatureIcon;


@end

NSString *const KMTTWColdIcon = @"ColdTemp";
NSString *const KMTTWHotIcon = @"HotTemp";

@implementation MTTWDetailsViewController

- (void)setNeedUpdateUI:(BOOL)needsUpdateUI
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateUI) object:nil];
    [self performSelector:@selector(updateUI)];
}

- (void)updateUI
{
    MTTWWeatherCondition *condition = self.region.currectCondition;
    self.regionNameLabel.text = self.region.name;
    self.maxTemparatureLabel.text = [@(condition.temperature) stringValue];
    self.windSpeedLabel.text = [@(condition.windSpeed) stringValue];
    self.weatheDescriptionLabel.text = condition.weatherDescription;
    if (condition.temperature > 0)
    {
        self.maxTemparatureLabel.textColor = [UIColor orangeColor];
        self.temperatureIcon.image = [UIImage imageNamed:KMTTWHotIcon];
    }
    else
    {
        self.temperatureIcon.image = [UIImage imageNamed:KMTTWColdIcon];
        self.maxTemparatureLabel.textColor = [UIColor blueColor];
    }

    [self.weathrIconImageView loadImageFromRemotePath:condition.weatherIconPath];

    [UIView animateWithDuration:1.0 animations:
    ^{
        self.windDirectionIconImageView.transform = CGAffineTransformMakeRotation(2.0 * M_PI  - M_PI / 8.0 * (condition.windDirection - 1));
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];



    // Do any additional setup after loading the view from its nib.
}

- (void)setRegion:(MTTWRegion *)region
{
    if (_region != region)
    {
        _region = region;
        self.needUpdateUI = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
