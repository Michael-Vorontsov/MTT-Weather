//
//  MTTWWeatherCondition.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTTWDailyForecast, MTTWRegion;

@interface MTTWWeatherCondition : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSNumber * humidity;
@property (nonatomic, retain) NSNumber * skyState;
@property (nonatomic, retain) NSNumber * windDirection;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * windSpeed;
@property (nonatomic, retain) MTTWRegion *region;
@property (nonatomic, retain) MTTWDailyForecast *forecast;

@end
