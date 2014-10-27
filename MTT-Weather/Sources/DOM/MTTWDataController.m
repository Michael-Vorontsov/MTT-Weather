//
//  MTTWDataController.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/25/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWDataController.h"

@interface MTTWDataController()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *storeCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *rootContext;
@property (nonatomic, strong) NSURL *storageURL;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *syncContext;

@end

#pragma mark -

static MTTWDataController* sMTTWSharedDataController = nil;

@implementation MTTWDataController

+ (MTTWDataController *)sharedController
{
    //    @synchronized(self)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
      if (nil == sMTTWSharedDataController)
      {
          NSURL *applicationDocumentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
          NSURL *storeURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:@"MTTWDataStorage.sqlite"];
          NSAssert(storeURL != nil, @"Invalid URL for storing");
          if (storeURL)
          {
              sMTTWSharedDataController = [[self alloc] initWithFileURL:storeURL];
              [sMTTWSharedDataController mainContext];
          }
      }
    });
    return sMTTWSharedDataController;
}

- (id)initWithFileURL:(NSURL *)url
{
    self = [super init];
    if (nil != self)
    {
        _storageURL = url;
    }
    return self;
}

#pragma mark - Contexts -

- (NSManagedObjectContext *)rootContext
{
    if (_rootContext != nil)
    {
        return _rootContext;
    }

    @synchronized (self)
    {
        NSPersistentStoreCoordinator *coordinator = [self storeCoordinator];
        if (coordinator != nil)
        {
            _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_rootContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_rootContext setPersistentStoreCoordinator:coordinator];
        }
    }

    return _rootContext;
}

- (NSManagedObjectContext *)mainContext
{
    if (nil == _mainContext)
    {
        @synchronized (self)
        {
            _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            _mainContext.parentContext = self.rootContext;
        }
    }
    return _mainContext;
}


- (NSManagedObjectContext*)syncContext
{
    if (nil == _syncContext)
    {
        _syncContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _syncContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        _syncContext.parentContext = self.mainContext;
    }

    return _syncContext;
}

+ (void)saveChangesInContext:(NSManagedObjectContext *)context recursive:(BOOL)hadSaveRecursive
{
    __block NSError *error = nil;
    do
    {
        [context performBlockAndWait:
         ^{
             [context save:&error];
             if (nil != error)
             {
                 NSLog(@"Error occured while saving changes to context: %@", error);
             }
         }];
        context = [context parentContext];
    } while (hadSaveRecursive && nil != context && nil == error);
}

#pragma mark - Creating Persistent Store and Data Model -

- (NSPersistentStoreCoordinator *)storeCoordinator
{
    if (_storeCoordinator != nil)
    {
        return _storeCoordinator;
    }

    @synchronized (self)
    {
        NSError *error = nil;
        _storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];

        if (![_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storageURL options:nil error:&error])
        {
            NSError *wipeError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self.storageURL.path error:&wipeError];
            if (nil == wipeError)
            {
                NSLog(@"Wipe DB!");
                self.storeCoordinator = nil;
                return self.storeCoordinator;
            }
            else
            {
                NSError* metadataObtainingError = nil;
                NSDictionary* metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.storageURL error:&metadataObtainingError];

                NSLog(@"Error waddinf persisten storeCoordinator: %@\n MetaData: %@\n Metadata obtaining error: %@",
                      error, metadata, metadataObtainingError);

                NSAssert(YES, @"Persisten storeCoordinator error!");
                _storeCoordinator = nil;
                _model = nil;
            }
        }
    }
    return _storeCoordinator;
}

- (NSManagedObjectModel *)model
{
    if (_model != nil)
    {
        return _model;
    }

    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"MTTWDataModel" withExtension:@"momd"];
    _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _model;
}

- (void)wipeDB
{
    NSError *storeError = nil;
    self.rootContext = nil;
    self.mainContext = nil;
    self.syncContext = nil;
    [self.storeCoordinator removePersistentStore:self.storeCoordinator.persistentStores.lastObject error:&storeError];
    NSError *fileError = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.storageURL.path error:&fileError];
    NSAssert(nil == storeError && nil == fileError, @"");
    self.storeCoordinator = nil;
}

- (NSFetchRequest *)requestWithRegionName:(NSString *)name
{
    return [self.model fetchRequestFromTemplateWithName:@"CityByName" substitutionVariables:@{@"NAME" : name}];
}


@end
