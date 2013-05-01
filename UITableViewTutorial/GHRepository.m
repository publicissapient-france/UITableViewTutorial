//
// Created by Alexis Kinsella on 30/04/13.
// Copyright (c) 2013 Xebia. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "GHRepository.h"
@implementation GHRepository


- (NSString *)description_ {
    return [NSString stringWithFormat:@"%@ -  %@ Forks - %@ Watchers - %@ issues", self.language ? self.language : @"No Language", self.forks, self.watchers, self.open_issues];
}

@end