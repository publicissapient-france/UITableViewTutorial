//
// Created by Alexis Kinsella on 30/04/13.
// Copyright (c) 2013 Xebia. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define XBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define XBLog(...)
#endif

#ifdef DEBUG
#define XBLogVerbose(fmt, ...) XBLog(fmt, ##__VA_ARGS__)
#define XBLogDebug(fmt, ...)   XBLog(fmt, ##__VA_ARGS__)
#define XBLogInfo(fmt, ...)    XBLog(fmt, ##__VA_ARGS__)
#else
#define XBLogVerbose(fmt, ...)
#define XBLogDebug(...)
#define XBLogInfo(fmt, ...)
#endif

#define XBLogWarn(fmt, ...)    XBLog(fmt, ##__VA_ARGS__)
#define XBLogError(fmt, ...)   XBLog(fmt, ##__VA_ARGS__)

