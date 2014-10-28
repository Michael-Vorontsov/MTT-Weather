//
//  MTTWObjectBuilderTest.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/27/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MTTWObjectBuilder.h"

#import "MTTWDailyForecast.h"
#import "MTTWWeatherCondition.h"
#import "MTTWRegion.h"

@interface MTTWObjectBuilderTest : XCTestCase



@end

@implementation MTTWObjectBuilderTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testObjectBuilderWithJSONObject
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"kiev-response" withExtension:@"json"];
    XCTAssertNotNil(url);
    NSData *data = [NSData dataWithContentsOfURL:url];
    XCTAssertNotNil(data);
    NSError *error = nil;
    id collection = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(collection);

    MTTWRegion *region = [MTTWObjectBuilder regionWithDictionary:collection];
    XCTAssertNotNil(region);
    XCTAssertNil([MTTWObjectBuilder lastError]);

    XCTAssertEqualObjects(region.name, @"Kiev, Ukraine");
    XCTAssertEqual([region.forecasts count], 2);

// ... etc ...

}

- (void)testObjectBuilderWithErrorJSONObject
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"unknown-location" withExtension:@"json"];
    XCTAssertNotNil(url);
    NSData *data = [NSData dataWithContentsOfURL:url];
    XCTAssertNotNil(data);
    NSError *error = nil;
    id collection = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(collection);

    MTTWRegion *region = [MTTWObjectBuilder regionWithDictionary:collection];
    XCTAssertNil(region);

    error = [MTTWObjectBuilder lastError];
    XCTAssertNotNil(error);
    NSDictionary *userInfo = error.userInfo;
    XCTAssertEqual(error.code, kMTTWErrorCodeAPIReturnError);
    NSString *message = [[userInfo [@"error"] lastObject] objectForKey: @"msg"];
    XCTAssertEqualObjects(message, @"Unable to find any matching weather location to the query submitted!");

}

- (void)testObjectBuilderWithNoData
{
    XCTAssertNil([MTTWObjectBuilder regionWithDictionary:nil]);
    NSError *error = [MTTWObjectBuilder lastError];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, kMTTWErrorCodeNoData);

    XCTAssertNil([MTTWObjectBuilder regionWithDictionary:@{}]);
    error = [MTTWObjectBuilder lastError];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, kMTTWErrorCodeNoData);

    XCTAssertNil([MTTWObjectBuilder regionWithDictionary:(NSDictionary *)@""]);
    error = [MTTWObjectBuilder lastError];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, kMTTWErrorCodeNoData);

}

- (void)testPerformanceTest
{
    [self measureBlock:
    ^{
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"kiev-response" withExtension:@"json"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *error = nil;
        id collection = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [MTTWObjectBuilder regionWithDictionary:collection];
    }];
}

@end
