//
//  MTTWWeatherCondition.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWWeatherCondition.h"
#import "MTTWDailyForecast.h"
#import "MTTWRegion.h"

NSString *const kMTTWWeatherConditionEntityName = @"WeatherCondition";

@implementation MTTWWeatherCondition

@dynamic time;
@dynamic temperature;
@dynamic humidity;
@dynamic skyState;
@dynamic windDirection;
@dynamic pressure;
@dynamic windSpeed;
@dynamic region;
@dynamic forecast;
@dynamic weatherIconPath;

@end
