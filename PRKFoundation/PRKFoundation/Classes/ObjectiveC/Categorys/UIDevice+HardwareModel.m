//
//  UIDevice+HardwareModel.m
//  PKCore
//
//  Created by zhongsheng on 13-9-17.
//  Copyright (c) 2013年 passerbycrk. All rights reserved.
//

#import "UIDevice+HardwareModel.h"
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice (HardwareModel)

#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}

- (BOOL)isSimulator
{
    
    return ([self.platform rangeOfString:@"x86"].location != NSNotFound);
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSInteger) results;
}

- (NSInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSInteger) busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSInteger) maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

- (NSNumber *) totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (UIDevicePlatform) platformType
{
    return [UIDevice platformTypeForString:[self platform]];
}


- (NSString *) platformString
{
    return [UIDevice platformStringForType:[self platformType]];
}

+ (NSInteger) platformTypeForString:(NSString *)platform
{
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDeviceiPhone1;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDeviceiPhone3G;
    if ([platform hasPrefix:@"iPhone2"])            return UIDeviceiPhone3GS;
    if ([platform isEqualToString:@"iPhone3,1"])    return UIDeviceiPhone4GSM;
    if ([platform isEqualToString:@"iPhone3,2"])    return UIDeviceiPhone4GSMRevA;
    if ([platform isEqualToString:@"iPhone3,3"])    return UIDeviceiPhone4CDMA;
    if ([platform hasPrefix:@"iPhone4"])            return UIDeviceiPhone4S;
    if ([platform isEqualToString:@"iPhone5,1"])    return UIDeviceiPhone5GSM;
    if ([platform isEqualToString:@"iPhone5,2"])    return UIDeviceiPhone5CDMA;
    if ([platform isEqualToString:@"iPhone5,3"])    return UIDeviceiPhone5CGSM;
    if ([platform isEqualToString:@"iPhone5,4"])    return UIDeviceiPhone5CGSMCDMA;
    if ([platform isEqualToString:@"iPhone6,1"])    return UIDeviceiPhone5SGSM;
    if ([platform isEqualToString:@"iPhone6,2"])    return UIDeviceiPhone5SGSMCDMA;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDeviceiPhone6Plus;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDeviceiPhone6;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDeviceiPod1;
    if ([platform isEqualToString:@"iPod2,2"])      return UIDeviceiPod3;
    if ([platform hasPrefix:@"iPod2"])              return UIDeviceiPod2;
    if ([platform hasPrefix:@"iPod3"])              return UIDeviceiPod3;
    if ([platform hasPrefix:@"iPod4"])              return UIDeviceiPod4;
    if ([platform hasPrefix:@"iPod5"])              return UIDeviceiPod5;
    
    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDeviceiPad1;
    if ([platform hasPrefix:@"iPad2"])
    {
        NSInteger submodel = [ UIDevice getSubmodel:platform ];
        if ( submodel <= 4 )
        {
            return UIDeviceiPad2;
        } else
        {
            return UIDeviceiPadMini;
        }
    }
    if ([platform hasPrefix:@"iPad3"])
    {
        NSInteger submodel = [ UIDevice getSubmodel:platform ];
        if ( submodel <= 3 )
        {
            return UIDeviceTheNewiPad;
        } else
        {
            return UIDeviceiPad4G;
        }
    }
    
    if ([platform isEqualToString:@"iPad4,1"])    return UIDeviceiPadAir;
    if ([platform isEqualToString:@"iPad4,2"])    return UIDeviceiPadAirLTE;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceiPhoneSimulatoriPhone : UIDeviceiPhoneSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

+ (NSString *) platformStringForType:(NSInteger)platformType
{
    switch (platformType)
    {
        case UIDeviceiPhone1:               return IPHONE_1_NAMESTRING;
        case UIDeviceiPhone3G:              return IPHONE_3G_NAMESTRING;
        case UIDeviceiPhone3GS:             return IPHONE_3GS_NAMESTRING;
        case UIDeviceiPhone4GSM:            return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4GSMRevA:        return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4CDMA:           return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4S:              return IPHONE_4S_NAMESTRING;
        case UIDeviceiPhone5GSM:            return IPHONE_5_NAMESTRING;
        case UIDeviceiPhone5CDMA:           return IPHONE_5_NAMESTRING;
        case UIDeviceiPhone5CGSM:           return IPHONE_5C_NAMESTRING;
        case UIDeviceiPhone5CGSMCDMA:       return IPHONE_5C_NAMESTRING;
        case UIDeviceiPhone5SGSM:           return IPHONE_5S_NAMESTRING;
        case UIDeviceiPhone5SGSMCDMA:       return IPHONE_5S_NAMESTRING;
        case UIDeviceiPhone6:               return IPHONE_6_NAMESTRING;
        case UIDeviceiPhone6Plus:           return IPHONE_6_PLUS_NAMESTRING;
        case UIDeviceUnknowniPhone:         return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPod1:                 return IPOD_1_NAMESTRING;
        case UIDeviceiPod2:                 return IPOD_2_NAMESTRING;
        case UIDeviceiPod3:                 return IPOD_3_NAMESTRING;
        case UIDeviceiPod4:                 return IPOD_4_NAMESTRING;
        case UIDeviceiPod5:                 return IPOD_5_NAMESTRING;
        case UIDeviceUnknowniPod:           return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPad1 :                return IPAD_1_NAMESTRING;
        case UIDeviceiPad2 :                return IPAD_2_NAMESTRING;
        case UIDeviceTheNewiPad :           return THE_NEW_IPAD_NAMESTRING;
        case UIDeviceiPad4G :               return IPAD_4G_NAMESTRING;
        case UIDeviceiPadAir :              return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadAirLTE :           return IPAD_AIR_LTE_NAMESTRING;
        case UIDeviceiPadMini :             return IPAD_MINI_NAMESTRING;
        case UIDeviceUnknowniPad :          return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 :             return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 :             return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 :             return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV:        return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPhoneSimulator:       return IPHONE_SIMULATOR_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPad:   return IPHONE_SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV:      return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA:                 return IFPGA_NAMESTRING;
            
        default:                            return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

+ (NSString *) platformStringForPlatform:(NSString *)platform
{
    NSInteger platformType = [UIDevice platformTypeForString:platform];
    return [UIDevice platformStringForType:platformType];
}

+ (BOOL) hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale == 2.0f);
}

+ (NSString *) imageSuffixRetinaDisplay
{
    return @"@2x";
}

+ (BOOL) has4InchDisplay
{
    return ([UIScreen mainScreen].bounds.size.height == 568);
}

+ (NSString *) imageSuffix4InchDisplay
{
    return @"-568h";
}

- (UIDeviceFamily) deviceFamily
{
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}

#pragma mark - system version
- (NSInteger) deviceSystemMajorVersion {
    static NSInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+( NSInteger )getSubmodel:( NSString* )platform
{
    NSInteger submodel = -1;
    
    NSArray* components = [ platform componentsSeparatedByString:@"," ];
    if ( [ components count ] >= 2 )
    {
        submodel = [ [ components objectAtIndex:1 ] intValue ];
    }
    return submodel;
}
@end
