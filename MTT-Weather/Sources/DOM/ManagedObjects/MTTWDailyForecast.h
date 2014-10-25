//
//  MTTWDailyForecast.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTTWDailyForecast, MTTWWeatherCondition;

@interface MTTWDailyForecast : NSManagedObject

@property (nonatomic, retain) NSNumber * maxTemp;
@property (nonatomic, retain) NSNumber * minTemp;
@property (nonatomic, retain) NSDate * sunrise;
@property (nonatomic, retain) NSDate * sunset;
@property (nonatomic, retain) MTTWDailyForecast *region;
@property (nonatomic, retain) NSSet *hourly;
@end

@interface MTTWDailyForecast (CoreDataGeneratedAccessors)

- (void)addHourlyObject:(MTTWWeatherCondition *)value;
- (void)removeHourlyObject:(MTTWWeatherCondition *)value;
- (void)addHourly:(NSSet *)values;
- (void)removeHourly:(NSSet *)values;

@end
