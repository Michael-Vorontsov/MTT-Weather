//
//  MTTWDataController.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MTTWDataController : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *syncContext;

+ (MTTWDataController *)sharedController;

+ (void)saveChangesInContext:(NSManagedObjectContext *)context recursive:(BOOL)hadSaveRecursive;

- (id)initWithFileURL:(NSURL *)url;

- (void)wipeDB;

@end
