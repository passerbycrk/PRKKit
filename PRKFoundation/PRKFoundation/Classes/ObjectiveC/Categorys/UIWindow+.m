//
//  UIWindow+.m
//  iPhoneVideo
//
//  Created by MingLQ on 2011-10-18.
//  Copyright 2011 SOHU. All rights reserved.
//

#import "UIWindow+.h"


@implementation UIWindow (Motion)

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([super respondsToSelector:_cmd]) {
        [super motionBegan:motion withEvent:event];
    }
} 

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([super respondsToSelector:_cmd]) {
        [super motionEnded:motion withEvent:event];
    }
    
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PRKEventSubtypeMotionShakeNotification object:self];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([super respondsToSelector:_cmd]) {
        [super motionCancelled:motion withEvent:event];
    }
    
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PRKEventSubtypeMotionShakeNotification object:self];
    }
} 

@end

