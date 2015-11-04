//
//  Reachability+NetworkType.m
//  Passerbycrk
//
//  Created by dabing on 15/6/8.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import "Reachability+NetworkType.h"

typedef NS_ENUM(NSInteger, WWANType) {
    WWANTypeNotAvailable    = - 1,          // can not detect
    WWANTypeNone            = 0,            // has not
    WWANType2G              = 2,
    WWANType3G              = 3,
    WWANType4G              = 4,
    WWANTypeUnknown         = NSIntegerMax  // has, but unknown
};

@interface Reachability (WWANType)

+ (BOOL)isWWANTypeAvailable;
+ (WWANType)currentWWANType;

@end

@implementation Reachability (NetworkType)

- (NetworkType)currentNetworkType {
    if ([self notReachable]) {
        return NetworkTypeNone;
    }
    
    if ([self reachableViaWiFi]) {
        return NetworkTypeWiFi;
    }
    
    if ([self reachableViaWWAN]) {
        switch ([Reachability currentWWANType]) {
            case WWANType2G:
                return NetworkType2G;
            case WWANType3G:
                return NetworkType3G;
            case WWANType4G:
                return NetworkType4G;
            default:
                return NetworkTypeUnknownWWAN;
        }
    }
    
    return NetworkTypeNone; // NetworkTypeUnknown?
}

- (BOOL)notReachable {
    return [self currentReachabilityStatus] == NotReachable;
}

- (BOOL)reachableViaWiFi {
    return [self currentReachabilityStatus] == ReachableViaWiFi;
}

- (BOOL)reachableViaWWAN {
    return [self currentReachabilityStatus] == ReachableViaWWAN;
}

- (BOOL)reachableViaWWAN2G {
    return [self reachableViaWWAN] && [Reachability isWWANTypeAvailable] && [Reachability currentWWANType] == WWANType2G;
}

- (BOOL)reachableViaWWAN3G {
    return [self reachableViaWWAN] && [Reachability isWWANTypeAvailable] && [Reachability currentWWANType] == WWANType3G;
}

- (BOOL)reachableViaWWAN4G {
    return [self reachableViaWWAN] && [Reachability isWWANTypeAvailable] && [Reachability currentWWANType] == WWANType4G;
}

@end

@implementation Reachability (CTTelephonyNetworkInfo)

+ (CTTelephonyNetworkInfo *)sharedTelephonyNetworkInfo {
    static CTTelephonyNetworkInfo *SharedTelephonyNetworkInfo = nil;
    
    if (SharedTelephonyNetworkInfo) {
        return SharedTelephonyNetworkInfo;
    }
    
    @synchronized(self) {
        if (!SharedTelephonyNetworkInfo) {
            SharedTelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        }
    }
    
    return SharedTelephonyNetworkInfo;
}

+ (NSString *)currentRadioAccessTechnology {
    return ([[self sharedTelephonyNetworkInfo] respondsToSelector:@selector(currentRadioAccessTechnology)]
            ? [self sharedTelephonyNetworkInfo].currentRadioAccessTechnology
            : nil);
}

@end

@implementation Reachability (WWANType)

+ (BOOL)isWWANTypeAvailable {
    return [[self sharedTelephonyNetworkInfo] respondsToSelector:@selector(currentRadioAccessTechnology)];
}

+ (WWANType)currentWWANType {
    if (![self isWWANTypeAvailable]) {
        return WWANTypeNotAvailable;
    }
    
    NSString *currentRadioAccessTechnology = [self currentRadioAccessTechnology];
    if (!currentRadioAccessTechnology) {
        return WWANTypeNone;
    }
    
    static NSDictionary *WWANTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // @see https://github.com/appscape/open-rmbt-ios/blob/6125831eadf02ffb4bf356ab1221453ecc6b0e82/Sources/RMBTConnectivity.m
        WWANTypes = @{ CTRadioAccessTechnologyGPRS:            @(WWANType2G),
                       CTRadioAccessTechnologyEdge:            @(WWANType2G),
                       
                       CTRadioAccessTechnologyCDMA1x:          @(WWANType2G),
                       CTRadioAccessTechnologyCDMAEVDORev0:    @(WWANType2G),
                       CTRadioAccessTechnologyCDMAEVDORevA:    @(WWANType2G),
                       CTRadioAccessTechnologyCDMAEVDORevB:    @(WWANType2G),
                       CTRadioAccessTechnologyeHRPD:           @(WWANType2G),
                       
                       CTRadioAccessTechnologyWCDMA:           @(WWANType3G),
                       CTRadioAccessTechnologyHSDPA:           @(WWANType3G),
                       CTRadioAccessTechnologyHSUPA:           @(WWANType3G),
                       
                       CTRadioAccessTechnologyLTE:             @(WWANType4G) };
    });
    
    NSNumber *typeNumber = [WWANTypes objectForKey:[self currentRadioAccessTechnology]];
    return typeNumber ? [typeNumber integerValue] : WWANTypeUnknown;
}

@end
