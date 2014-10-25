//
//  MTTWRegion.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTTWDailyForecast, MTTWWeatherCondition;

@interface MTTWRegion : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * timeZone;
@property (nonatomic, retain) NSSet *forecasts;
@property (nonatomic, retain) MTTWWeatherCondition *currectCondition;
@end

@interface MTTWRegion (CoreDataGeneratedAccessors)

- (void)addForecastsObject:(MTTWDailyForecast *)value;
- (void)removeForecastsObject:(MTTWDailyForecast *)value;
- (void)addForecasts:(NSSet *)values;
- (void)removeForecasts:(NSSet *)values;

@end
