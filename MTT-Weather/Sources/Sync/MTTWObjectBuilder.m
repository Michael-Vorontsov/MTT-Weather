//
//  MTTWObjectBuilder.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWObjectBuilder.h"
#import "MTTWDataController.h"

#import "MTTWDailyForecast.h"
#import "MTTWRegion.h"
#import "MTTWWeatherCondition.h"


@interface MTTWObjectBuilder()

@property (nonatomic, strong) MTTWDataController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong) NSArray *windDirectionArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

NSString *const kMTTWObjectBuildeErrorDomain = @"ObjectBuilderErrorDomain";

NSString *const kMTTWDataKey = @"data";
NSString *const kMTTWErrorKey = @"error";

NSString *const kMTTWCurrentConditionKey = @"current_condition";
NSString *const kMTTWTemparatureKey = @"temp_C";
NSString *const kMTTWPressureKey = @"pressure";
NSString *const kMTTWWindDirectionKey = @"winddir16Point";
NSString *const kMTTWWindSpeedKey = @"windspeedKmph";
NSString *const kMTTWWeatherIconURLKey = @"weatherIconUrl";
NSString *const kMTTWWeatherDescritionValueKey = @"weatherDesc";

NSString *const kMTTWValueKey = @"value";

NSString *const kMTTWWeatherKey = @"weather";
NSString *const kMTTWDateKey = @"date";


NSString *const kMTTWRequestKey = @"request";
NSString *const kMTTWQueryKey = @"query";

NSString *const kMTTWMaxTemparatureKey = @"maxtempC";
NSString *const kMTTWMinTemparatureKey = @"mintempC";
NSString *const kMTTWHourlyKey = @"hourly";

static MTTWObjectBuilder *sMTTWSharedObjectBuilder = nil;

@implementation MTTWObjectBuilder

+ (MTTWObjectBuilder *)sharedBuilder
{
    //    @synchronized(self)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        if (nil == sMTTWSharedObjectBuilder)
        {
            sMTTWSharedObjectBuilder = [[MTTWObjectBuilder alloc] init];
        }
    });
    return sMTTWSharedObjectBuilder;
}

- (MTTWDataController *)dataController
{
    if (nil == _dataController)
    {
        _dataController = [MTTWDataController sharedController];
    }
    return _dataController;
}

- (NSDateFormatter *)dateFormatter
{
    if (nil == _dateFormatter)
    {
//        _dateFormatter = [NSDateFormatter dateFormatFromTemplate:@"YYYY-MM-DD" options:0 locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
//        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
//        _dateFormatter.timeStyle = NSDateFormatterNoStyle;

    }
    return _dateFormatter;
}

+ (NSError *)lastError
{
    return [[MTTWObjectBuilder sharedBuilder] lastError];
}

#pragma mark - Objects form dictionary processing

+ (MTTWRegion *)regionWithDictionary:(NSDictionary *)dictionaryRepresentation
{
   return  [[MTTWObjectBuilder sharedBuilder] regionWithDictionary:dictionaryRepresentation];
}

- (MTTWWeatherCondition *)conditionInRegion:(MTTWRegion *)region withDictionary:(NSDictionary *)dictionaryRepresentation
{
    MTTWWeatherCondition *currentCondition = region.currectCondition;
    if (nil == currentCondition)
    {
        currentCondition = [NSEntityDescription insertNewObjectForEntityForName:kMTTWWeatherConditionEntityName
                                                         inManagedObjectContext:region.managedObjectContext];
        currentCondition.region = region;
    }

    NSDictionary *weatherDescription = [dictionaryRepresentation[kMTTWWeatherDescritionValueKey] lastObject];
    currentCondition.weatherDescription = weatherDescription[kMTTWValueKey];

    NSDictionary *weatherDesctriptionURL = [dictionaryRepresentation[kMTTWWeatherIconURLKey] lastObject];
    currentCondition.weatherIconPath = weatherDesctriptionURL[kMTTWValueKey];

    NSString *temp = dictionaryRepresentation[kMTTWTemparatureKey];
    currentCondition.temperature = [temp integerValue];
    currentCondition.pressure = [dictionaryRepresentation[kMTTWPressureKey] integerValue];
    currentCondition.windDirection = [self directionFromString:dictionaryRepresentation[kMTTWWindDirectionKey]];
    currentCondition.windSpeed = [dictionaryRepresentation[kMTTWWindSpeedKey] integerValue];
    return currentCondition;
}

- (MTTWDailyForecast *)forecastInRegion:(MTTWRegion *)region withDictionary:(NSDictionary *)dictionaryRepresentation
{
    NSString *dateString = dictionaryRepresentation[kMTTWDateKey];
    NSDate *date = [self.dateFormatter dateFromString:dateString];

    if (nil == date)
    {
        self.lastError = [NSError errorWithDomain:kMTTWObjectBuildeErrorDomain code:kMTTWErrorCodeNoData userInfo:nil];
        return nil;
    }

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMTTWDailyForecastEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"region == %@ AND date == %@", region, date];

    NSError *error = nil;
    NSArray *resultForecasts = [region.managedObjectContext executeFetchRequest:request error:&error];
    NSAssert([resultForecasts count] < 2, nil);
    MTTWDailyForecast *forecast = [resultForecasts lastObject];
    if (nil == forecast)
    {
        forecast = [NSEntityDescription insertNewObjectForEntityForName:kMTTWDailyForecastEntityName inManagedObjectContext:region.managedObjectContext];
        forecast.date = date;
        forecast.region = region;
    }

    forecast.maxTemp = [dictionaryRepresentation[kMTTWMaxTemparatureKey] integerValue];
    forecast.minTemp = [dictionaryRepresentation[kMTTWMinTemparatureKey] integerValue];

    return forecast;
}

- (NSArray *)windDirectionArray
{
    if (nil == _windDirectionArray)
    {
        _windDirectionArray = @[@"S", @"SSE", @"SE", @"ESE", @"E", @"ENE", @"NE", @"NNE", @"N", @"NNW", @"NW", @"WNW", @"W", @"WSW", @"SW", @"SSW"];
    }
    return _windDirectionArray;
}

- (MTTWDirection)directionFromString:(NSString *)directionString
{
    MTTWDirection result = kMTTWDirectionUnknown;
    if ([self.windDirectionArray containsObject:directionString])
    {
        result = [self.windDirectionArray indexOfObject:directionString] + 1;
    }
    return result;
}

- (NSError *)errorWithDictionary:(NSDictionary *)dictionaryRepresentation
{
    return [NSError errorWithDomain:kMTTWObjectBuildeErrorDomain code:kMTTWErrorCodeAPIReturnError userInfo:dictionaryRepresentation];
}

- (MTTWRegion *)regionWithDictionary:(NSDictionary *)dictionaryRepresentation
{
    self.lastError = nil;
    
    if (![dictionaryRepresentation isKindOfClass:[NSDictionary class]])
    {

        self.lastError = [NSError errorWithDomain:kMTTWObjectBuildeErrorDomain code:kMTTWErrorCodeNoData userInfo:nil];
        return nil;
    }


    NSDictionary *dataDictionary = dictionaryRepresentation[kMTTWDataKey];

    if (nil == dataDictionary)
    {
        self.lastError = [NSError errorWithDomain:kMTTWObjectBuildeErrorDomain code:kMTTWErrorCodeNoData userInfo:nil];
        return nil;
    }
    else if (nil != dataDictionary[kMTTWErrorKey])
    {
        self.lastError = [self errorWithDictionary:dataDictionary];
        return nil;
    }
    NSManagedObjectContext *context = self.dataController.syncContext;
    __block MTTWRegion *region = nil;
    [context performBlockAndWait:
    ^{
        region = [self regionWithDataDictionary:dataDictionary inContext:context];
    }];
    NSError *error = nil;
    [MTTWDataController saveChangesInContext:context recursive:YES];
//    [context save:&error];
    NSAssert(nil == error, nil);
    return region;
}

- (MTTWRegion *)regionWithDataDictionary:(NSDictionary *)dictionaryRepresentation inContext:(NSManagedObjectContext *)context
{
    NSString *regionName = [dictionaryRepresentation[kMTTWRequestKey] lastObject][kMTTWQueryKey];

    NSFetchRequest *regionRequest = [self.dataController requestWithRegionName:regionName];
    NSError *error = nil;

    MTTWRegion *region = [[context executeFetchRequest:regionRequest error:&error] lastObject];
    if (nil == region)
    {
        region = [NSEntityDescription insertNewObjectForEntityForName:kMTTWRegionEntityName
                                               inManagedObjectContext:context];
        region.name = regionName;
    }

    [self conditionInRegion:region withDictionary:[dictionaryRepresentation[kMTTWCurrentConditionKey] lastObject]];


    NSArray *weatherForecastArray = dictionaryRepresentation[kMTTWWeatherKey];
    NSMutableSet *forecastsToRemove = [region.forecasts mutableCopy];
    for (NSDictionary *dailyForecastDictionary in weatherForecastArray)
    {
        [forecastsToRemove removeObject:[self forecastInRegion:region withDictionary:dailyForecastDictionary]];
    }
    [region removeForecasts:forecastsToRemove];
    return region;

}


@end
