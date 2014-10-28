//
//  MTTWIconImageView.h
//  MTT-Weather
//
//  Created by Mykhailo Vorontsov on 10/28/14.
//  Copyright (c) 2014 MTT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTTWIconImageView : UIImageView

- (void)loadImageFromRemoteURL:(NSURL *)imageURL;
- (void)loadImageFromRemotePath:(NSString *)address;

@end
