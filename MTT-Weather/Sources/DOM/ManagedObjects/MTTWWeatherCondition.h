//
//  MTTWWeatherCondition.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const kMTTWWeatherConditionEntityName;

typedef NS_ENUM(UInt16, MTTWDirection)
{
    kMTTWDirectionUnknown = 0,
    
    kMTTWDirectionS,
    kMTTWDirectionSSE,
    kMTTWDirectionSE,
    kMTTWDirectionESE,
    kMTTWDirectionE,
    kMTTWDirectionENE,
    kMTTWDirectionNE,
    kMTTWDirectionNNE,
    kMTTWDirectionN,
    kMTTWDirectionNNW,
    kMTTWDirectionNW,
    kMTTWDirectionWNW,
    kMTTWDirectionW,
    kMTTWDirectionWSW,
    kMTTWDirectionSW,
    kMTTWDirectionSSW,
};

@class MTTWDailyForecast, MTTWRegion;

@interface MTTWWeatherCondition : NSManagedObject

@property (nonatomic, retain) NSDate * time;

@property (nonatomic) int16_t temperature;
@property (nonatomic) uint16_t humidity;
@property (nonatomic) uint16_t skyState;

@property (nonatomic) uint16_t windDirection;

@property (nonatomic) uint16_t pressure;
@property (nonatomic) uint16_t windSpeed;

@property (nonatomic, retain) MTTWRegion *region;
@property (nonatomic, retain) MTTWDailyForecast *forecast;

@property (nonatomic, strong) NSString *weatherIconPath;

@end
