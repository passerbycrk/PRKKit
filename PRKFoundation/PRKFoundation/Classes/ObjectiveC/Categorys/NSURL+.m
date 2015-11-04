//
//  NSURL+_.m
//  Passerbycrk
//
//  Created by dabing on 15/6/12.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import "NSURL+.h"

@implementation NSURL (PRK)

- (BOOL)isAppURL {
    if ([self.host isEqualToString:@"itunes.apple.com"]
        || [self.host isEqualToString:@"phobos.apple.com"]) {
        return YES;
        
    } else if ([self.scheme isEqualToString:@"mailto"]
               || [self.scheme isEqualToString:@"tel"]
               || [self.scheme isEqualToString:@"sms"]) {
        return YES;
        
    } else {
        return NO;
    }
}

@end
