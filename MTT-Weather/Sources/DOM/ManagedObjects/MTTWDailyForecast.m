//
//  MTTWDailyForecast.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWDailyForecast.h"
#import "MTTWDailyForecast.h"
#import "MTTWWeatherCondition.h"

NSString *const kMTTWDailyForecastEntityName = @"DailyForecast";

@implementation MTTWDailyForecast

@dynamic maxTemp;
@dynamic minTemp;

@dynamic sunrise;
@dynamic sunset;

@dynamic region;
@dynamic hourly;

@dynamic date;

@end
