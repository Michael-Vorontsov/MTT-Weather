//
//  MTTWForecastSyncOperation.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWForecastSyncOperation.h"
#import "MTTWObjectBuilder.h"

@interface MTTWForecastSyncOperation()

@property (nonatomic, strong) NSURL *syncURL;
@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSError *syncError;

@end;

NSString *const kMTTWSyncAddressFormat = @"http://api.worldweatheronline.com/free/v2/weather.ashx?q=%@&format=json&num_of_days=2&key=%@";


@implementation MTTWForecastSyncOperation

+ (instancetype)syncOperationForRegionName:(NSString *)regionName
{
    return [[MTTWForecastSyncOperation alloc] initWithRegionName:regionName];
}

- (instancetype)init //Disable init, at least for now
{
    self = nil;
    return self;
}

- (instancetype)initWithRegionName:(NSString *)regionName // Designated initializer
{
    self = [super init];
    if (nil != self)
    {
        NSString *syncPath = [NSString stringWithFormat:kMTTWSyncAddressFormat, regionName, [MTTWForecastSyncOperation apiKey]];
        _syncURL = [NSURL URLWithString:syncPath];
    }
    return self;
}

+ (NSString *)apiKey
{
    return @"bdaaf16df2e9ef7eb6f4e40e5f51e83efee4cb3c";
}


- (NSData *)downloadData
{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;
    data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:self.syncURL]
        returningResponse:&response error:&error];
    if (nil != error || nil == data)
    {
        NSLog(@"Error while downloading data:\n Response:\n %@,\n\n Error:\n %@",
              response, error);
    }
    return data;
}

- (id)JSONObjectFromData:(NSData *)data
{
    NSError *error = nil;
    id collection = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (nil != error)
    {
        NSLog(@"Error while parsing data:\n Error:\n %@", error);
        [self cancel];
    }
    return collection;
}

- (id)objectFromJSON:(id)collection
{
    return nil;
}

- (void)main
{
    NSData *data = nil;
    if (![self isCancelled])
    {
        data = [self downloadData];
    }
    id collection = nil;
    if (![self isCancelled])
    {
        collection = [self JSONObjectFromData:data];
    }
//    id result = nil;
    if (![self isCancelled])
    {
       self.result = [MTTWObjectBuilder regionWithDictionary:collection];
    }
}

@end
