//
//  MTTWDailyForecast.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const kMTTWDailyForecastEntityName;

@class MTTWWeatherCondition;
@class MTTWRegion;

@interface MTTWDailyForecast : NSManagedObject

@property (nonatomic) int16_t maxTemp;
@property (nonatomic) int16_t minTemp;

@property (nonatomic, retain) NSDate * sunrise;
@property (nonatomic, retain) NSDate * sunset;

@property (nonatomic, retain) MTTWRegion *region;

@property (nonatomic, retain) NSSet *hourly;
@property (nonatomic, retain) NSDate *date;
@end

@interface MTTWDailyForecast (CoreDataGeneratedAccessors)

- (void)addHourlyObject:(MTTWWeatherCondition *)value;
- (void)removeHourlyObject:(MTTWWeatherCondition *)value;
- (void)addHourly:(NSSet *)values;
- (void)removeHourly:(NSSet *)values;

@end
