//
//  MTTWIconImageView.m
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/28/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import "MTTWIconImageView.h"

@interface MTTWIconImageView()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

static NSURL *sMTTWIconImagesCache = nil;

@implementation MTTWIconImageView

+ (NSURL *)cachedImagesLocalURL
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sMTTWIconImagesCache= [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
            inDomains:NSUserDomainMask] lastObject];
    });

    return sMTTWIconImagesCache;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (nil == _activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [self addSubview:_activityIndicator];
        _activityIndicator.center = self.center;

        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
            | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin
            | UIViewAutoresizingFlexibleRightMargin;

    }
    return  _activityIndicator;
}

- (void)loadImageFromRemotePath:(NSString *)address
{
    [self loadImageFromRemoteURL:[NSURL URLWithString:address]];
}


- (void)loadImageFromRemoteURL:(NSURL *)imageURL
{
    if (nil == imageURL)
    {
        return;
    }

    NSURL *cacheURL = [[MTTWIconImageView cachedImagesLocalURL] URLByAppendingPathComponent:imageURL.lastPathComponent];
    if ([[NSFileManager defaultManager]  fileExistsAtPath:[cacheURL path] isDirectory:nil])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:cacheURL.path];
        self.image = image;
    }
    else
    {
        NSURLSession *sessgion = [NSURLSession sharedSession];
        [self.activityIndicator startAnimating];
        [[sessgion downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
        {
            if (nil == error)
            {
                [[NSFileManager defaultManager] copyItemAtURL:location toURL:cacheURL error:&error];
            }
            if (nil == error)
            {
                UIImage *image = [UIImage imageWithContentsOfFile:cacheURL.path];
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    self.image = [image copy];
                });
            }
            dispatch_async(dispatch_get_main_queue(),
            ^{
               [self.activityIndicator stopAnimating];
            });
        }] resume];
    }
}

@end
