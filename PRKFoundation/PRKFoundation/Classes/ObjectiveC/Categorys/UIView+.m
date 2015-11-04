//
//  UIView+a.m
//  Passerbycrk
//
//  Created by dabing on 15/4/14.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import "UIView+.h"

@implementation UIView (PCK)

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
