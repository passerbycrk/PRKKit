//
//  UIDevice+HardwareModel.h
//  PKCore
//
//  Created by zhongsheng on 13-9-17.
//  Copyright (c) 2013年 passerbycrk. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1_NAMESTRING             @"iPhone 1"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING        @"iPhone 6 Plus"
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1_NAMESTRING               @"iPod touch 1"
#define IPOD_2_NAMESTRING               @"iPod touch 2"
#define IPOD_3_NAMESTRING               @"iPod touch 3"
#define IPOD_4_NAMESTRING               @"iPod touch 4"
#define IPOD_5_NAMESTRING               @"iPod touch 5"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1_NAMESTRING               @"iPad 1"
#define IPAD_2_NAMESTRING               @"iPad 2"
#define THE_NEW_IPAD_NAMESTRING         @"The new iPad"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_AIR_NAMESTRING             @"iPad Air (WiFi)"
#define IPAD_AIR_LTE_NAMESTRING         @"iPad Air (LTE)"

#define IPAD_MINI_NAMESTRING            @"iPad mini"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator"

typedef NS_ENUM(NSInteger, UIDevicePlatform) {
    UIDeviceUnknown,
    
    UIDeviceiPhoneSimulator,
    UIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    UIDeviceiPhoneSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDeviceiPhone1,
    UIDeviceiPhone3G,
    UIDeviceiPhone3GS,
    UIDeviceiPhone4,
    UIDeviceiPhone4GSM,
    UIDeviceiPhone4GSMRevA,
    UIDeviceiPhone4CDMA,
    UIDeviceiPhone4S,
    UIDeviceiPhone5,
    UIDeviceiPhone5GSM,
    UIDeviceiPhone5CDMA,
    UIDeviceiPhone5CGSM,
    UIDeviceiPhone5CGSMCDMA,
    UIDeviceiPhone5SGSM,
    UIDeviceiPhone5SGSMCDMA,
    UIDeviceiPhone6,
    UIDeviceiPhone6Plus,
    
    UIDeviceiPod1,
    UIDeviceiPod2,
    UIDeviceiPod3,
    UIDeviceiPod4,
    UIDeviceiPod5,
    
    UIDeviceiPad1,
    UIDeviceiPad2,
    UIDeviceTheNewiPad,
    UIDeviceiPad4G,
    UIDeviceiPadAir,
    UIDeviceiPadAirLTE,
    UIDeviceiPadMini,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceIFPGA,
    
};

typedef NS_ENUM(NSInteger, UIDeviceFamily) {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
    
};

@interface UIDevice (HardwareModel)

- (NSString *) platform;
- (NSString *) hwmodel;
- (NSString *) platformString;
- (UIDevicePlatform) platformType;
- (UIDeviceFamily) deviceFamily;

- (NSInteger) deviceSystemMajorVersion;

- (NSInteger) cpuFrequency;
- (NSInteger) busFrequency;

- (NSInteger) cpuCount;

- (NSInteger) totalMemory;
- (NSInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (BOOL) isSimulator;

@end

