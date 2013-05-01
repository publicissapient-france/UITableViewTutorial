//
// Created by Alexis Kinsella on 30/04/13.
// Copyright (c) 2013 Xebia. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "XBMappingProvider.h"

@interface GHOwner : NSObject

@property (nonatomic, strong) NSString *gravatar_id;

@property (nonatomic, strong, readonly) NSURL *avatarImageUrl;

@end