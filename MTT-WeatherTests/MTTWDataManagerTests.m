//
//  MTTWDataManagerTests.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MTTWRegion.h"
#import "MTTWWeatherCondition.h"
#import "MTTWDailyForecast.h"

#import "MTTWDataController.h"

@interface MTTWDataManagerTests : XCTestCase


@end

@implementation MTTWDataManagerTests

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDataManager
{
    MTTWDataController *sharedController = [MTTWDataController sharedController];

// Either Contexts exists
    XCTAssertNotNil(sharedController.syncContext);
    XCTAssertNotNil(sharedController.mainContext);


// Check concurency types of contexts
    XCTAssertEqual(sharedController.syncContext.concurrencyType, NSPrivateQueueConcurrencyType);
    XCTAssertEqual(sharedController.mainContext.concurrencyType, NSMainQueueConcurrencyType);


// Main context should be a parent of sync context
    XCTAssertEqualObjects(sharedController.syncContext.parentContext, sharedController.mainContext);

// Parent context of main context should have a private concurency type
// and should have a persistent store coordinator

    NSManagedObjectContext *rootContext = sharedController.mainContext.parentContext;
    XCTAssertNotNil(rootContext);
    XCTAssertNotNil(rootContext.persistentStoreCoordinator);
    XCTAssertNil(rootContext.parentContext);

    XCTAssertEqual(rootContext.concurrencyType, NSPrivateQueueConcurrencyType);

// Neither main nor sync context shouldn't have a persistent store coordinators directly
    XCTAssertEqualObjects(sharedController.syncContext.persistentStoreCoordinator,
        rootContext.persistentStoreCoordinator);
    XCTAssertEqualObjects(sharedController.syncContext.persistentStoreCoordinator,
        rootContext.persistentStoreCoordinator);

// Test persitent store

    NSPersistentStoreCoordinator *storeCoordinator = rootContext.persistentStoreCoordinator;

    XCTAssertEqual(storeCoordinator.persistentStores.count, 1);

// Test Persistent store
    NSPersistentStore *store = storeCoordinator.persistentStores.lastObject;
    XCTAssertEqualObjects(store.URL.lastPathComponent, @"MTTWDataStorage.sqlite");

//Test managed object model
    NSManagedObjectModel *model = storeCoordinator.managedObjectModel;
    XCTAssertNotNil(model);

// Test All Entities in Model
    NSArray *allEntitiesName = [model.entitiesByName allKeys];
    XCTAssertEqual([allEntitiesName count], 3);
    XCTAssertTrue([allEntitiesName containsObject:@"Region"]);
    XCTAssertTrue([allEntitiesName containsObject:@"DailyForecast"]);
    XCTAssertTrue([allEntitiesName containsObject:@"WeatherCondition"]);
}

@end
