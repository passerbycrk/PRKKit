//
//  UIDevice+Core.h
//  PKCore
//
//  Created by zhongsheng on 13-9-17.
//  Copyright (c) 2013年 passerbycrk. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  主要用来判断分辨率来做布局处理，scale可能不同
 */
typedef NS_ENUM(NSUInteger, PRK_ScreenType)
{
    PRK_ScreenTypeUndefined = 0,
    PRK_ScreenTypeClassic = 1,//3gs及以下
    PRK_ScreenTypeRetina = 2,//4&4s
    PRK_ScreenType4InchRetina = 3,//5&5s&5c
    PRK_ScreenType6 = 4,//6或者6+放大模式
    PRK_ScreenType6Plus = 5,//6+
    PRK_ScreenTypeIpadClassic = 6,//iPad 1,2,mini
    PRK_ScreenTypeIpadRetina = 7,//iPad 3以上,mini2以上
};

@interface UIDevice (Core)

// 设备唯一标示符
- (NSString *)uniqueGlobalDeviceIdentifier;

// 系统版本，以float形式返回
- (CGFloat)systemVersionByFloat;

// 是否Retina屏
- (BOOL) hasRetinaDisplay;

// mac地址 iOS < 7.0 才能取到
- (NSString *)macaddress NS_DEPRECATED_IOS(6_0, 7_0);

// 系统版本比较
- (BOOL)systemVersionLowerThan:(NSString*)version;
- (BOOL)systemVersionNotHigherThan:(NSString *)version;
- (BOOL)systemVersionHigherThan:(NSString*)version;
- (BOOL)systemVersionNotLowerThan:(NSString *)version;

// 内存信息
+ (unsigned long)freeMemory;
+ (unsigned long)usedMemory;

/*!
 *  判断当前屏幕类型（按分辨率分类）
 *
 *
 */
- (PRK_ScreenType)screenType;

/*!
 *  判断当前是否为 iPhone 6
 *
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone 6 作特殊处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale > 2.1; 3.屏幕高度为 736。这个判断可能在苹果发布新设备后失效
 *
 *  @return
 */
- (BOOL)prk_isIPhone6;

- (BOOL)prk_isIPhone6Plus;

@end
