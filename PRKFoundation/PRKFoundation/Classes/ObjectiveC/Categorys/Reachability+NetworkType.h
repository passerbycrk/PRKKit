//
//  Reachability+NetworkType.h
//  Passerbycrk
//
//  Created by dabing on 15/6/8.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
// NOTE: .h文件不可以以第一种方式import framework文件
//#import "Reachability.h"
#import <Reachability/Reachability.h>

typedef NS_ENUM(NSInteger, NetworkType) {
    NetworkTypeNone = 0,
    NetworkTypeWiFi = 1,
    NetworkType2G   = 2,
    NetworkType3G   = 3,
    NetworkType4G   = 4,
    NetworkTypeUnknownWWAN = NSIntegerMax
};

@interface Reachability (NetworkType)

- (BOOL)notReachable;
- (BOOL)reachableViaWiFi;
- (BOOL)reachableViaWWAN;

- (NetworkType)currentNetworkType;

- (BOOL)reachableViaWWAN2G;
- (BOOL)reachableViaWWAN3G;
- (BOOL)reachableViaWWAN4G;

@end

@interface Reachability (CTTelephonyNetworkInfo)

+ (CTTelephonyNetworkInfo *)sharedTelephonyNetworkInfo;
+ (NSString *)currentRadioAccessTechnology;

@end
