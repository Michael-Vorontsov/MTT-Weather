//
//  MTTWForecastSyncOperation.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTTWForecastSyncOperation : NSOperation

@property (nonatomic, strong, readonly) NSURL *syncURL;
@property (nonatomic, strong, readonly) id result;
@property (nonatomic, strong, readonly) NSError *syncError;

+ (instancetype)syncOperationForRegionName:(NSString *)regionName;
+ (NSString *)apiKey;

@end
