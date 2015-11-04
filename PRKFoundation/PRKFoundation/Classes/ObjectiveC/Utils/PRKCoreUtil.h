//
//  PasserbycrkUtil.h
//  Passerbycrk
//
//  Created by dabing on 15/4/22.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface PRKCoreUtil : NSObject

+ (void)moveDirectoryFrom:(NSString *)srcPath to:(NSString *)desPath;

+ (NSString *)makeDirectoryWithBase:(NSString *)basePath andSub:(NSString *)subPath createIfNotExist:(BOOL)isCreate;

+ (CGFloat)lineHeightWithFont:(UIFont *)font andLineCount:(NSInteger)count;

@end