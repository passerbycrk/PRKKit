//
//  UIWindow+.h
//  iPhoneVideo
//
//  Created by MingLQ on 2011-10-18.
//  Copyright 2011 SOHU. All rights reserved.
//

#import <UIKit/UIKit.h>


#define PRKEventSubtypeMotionShakeNotification @"PRKEventSubtypeMotionShakeNotification"


@interface UIWindow (Motion)

// @override
- (BOOL)canBecomeFirstResponder;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end

