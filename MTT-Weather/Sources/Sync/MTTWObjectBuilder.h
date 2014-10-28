//
//  MTTWObjectBuilder.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/26/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTTWRegion;

typedef NS_ENUM(NSInteger, MTTWErrorCodes)
{
    kMTTWErrorCodeNoData = 1,// Data abscent
    kMTTWErrorCodeAPIReturnError = 2,
};

@interface MTTWObjectBuilder : NSObject

+ (MTTWRegion *)regionWithDictionary:(NSDictionary *)dictionaryRepresentation;
+ (NSError *)lastError;
//+ (MTTWObjectBuilder *)sharedBuilder;

@end
