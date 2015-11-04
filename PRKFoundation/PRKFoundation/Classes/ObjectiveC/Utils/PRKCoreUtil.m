//
//  PasserbycrkUtil.m
//  Passerbycrk
//
//  Created by dabing on 15/4/22.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import "PRKCoreUtil.h"

@implementation PRKCoreUtil

// 移动文件夹
+ (void)moveDirectoryFrom:(NSString *)srcPath to:(NSString *)desPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *contents = [fileMgr contentsOfDirectoryAtPath:srcPath error:nil];
    [self.class makeDirectoryWithBase:desPath andSub:nil createIfNotExist:YES];
    
    for (NSString *onePath in contents)
    {
        BOOL isFolder = YES;
        NSString *srcOnePath = [srcPath stringByAppendingPathComponent:onePath];
        NSString *desOnePath = [desPath stringByAppendingPathComponent:onePath];
        if ([fileMgr fileExistsAtPath:srcOnePath isDirectory:&isFolder]) {
            if (isFolder) {
                [self.class moveDirectoryFrom:srcOnePath to:desOnePath];
            } else {
                [fileMgr moveItemAtPath:srcOnePath toPath:desOnePath error:nil];
            }
        }
    }
}

// 创建文件夹
+ (NSString *)makeDirectoryWithBase:(NSString *)basePath andSub:(NSString *)subPath createIfNotExist:(BOOL)isCreate {
    if (basePath) {
        basePath = [basePath stringByAppendingPathComponent:subPath];
        BOOL needCreateDirectory = YES;
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                [[NSFileManager defaultManager] removeItemAtPath:basePath error:nil];
            } else {
                needCreateDirectory = NO;
            }
        }
        
        if (needCreateDirectory && isCreate) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"cannot create directory at %@, error: %@", basePath, error);
                basePath = nil;
            }
        }
    }
    
    return basePath;
}

+ (CGFloat)lineHeightWithFont:(UIFont *)font andLineCount:(NSInteger)count {
    NSString *lineText = @"-";
    for (NSInteger i = 0; i < count; ++i)
        lineText = [lineText stringByAppendingString:@"\n|W|"];
    UILabel *lbl = [UILabel new];
    lbl.font = font;
    lbl.text = lineText;
    lbl.numberOfLines = count;
    [lbl sizeToFit];
    return lbl.frame.size.height;
}

@end
