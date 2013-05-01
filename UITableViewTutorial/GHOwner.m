//
// Created by Alexis Kinsella on 30/04/13.
// Copyright (c) 2013 Xebia. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GHOwner.h"


@implementation GHOwner

- (NSURL *)avatarImageUrl {
    NSString *gravatarUrlStr = [NSString stringWithFormat:@"https://secure.gravatar.com/avatar/%@?s=44&d=404", self.gravatar_id];
    return [NSURL URLWithString: gravatarUrlStr];
}

@end