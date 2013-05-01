//
// Created by Alexis Kinsella on 30/04/13.
// Copyright (c) 2013 Xebia. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GHOwner.h"

@interface GHRepository : NSObject

@property (nonatomic, strong) NSNumber *forks;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *open_issues;
@property (nonatomic, strong) GHOwner *owner;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *watchers;

@property (nonatomic, strong, readonly) NSString *description_;

@end