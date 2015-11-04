//
//  UIDevice+Core.m
//  PKCore
//
//  Created by zhongsheng on 13-9-17.
//  Copyright (c) 2013年 passerbycrk. All rights reserved.
//

#import "UIDevice+Core.h"
#import "NSString+Core.h"

// for macaddress
#import <sys/socket.h> // Per msqr
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <net/if.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <sys/mount.h>
#import <mach/mach.h>


@implementation UIDevice (Core)

// 设备唯一标示符
- (NSString *)uniqueGlobalDeviceIdentifier
{
    /*
    if ([self systemVersionLowerThan:@"6.0"]) {
        NSString *macaddress = [self macaddress];
        return [macaddress md5]; // mac地址在7.0以后被废弃，6.0后提供了UUID方法
    }
     //*/
    return [self.identifierForVendor UUIDString]; // 每次重新安装都会刷新
}

// 系统版本，以float形式返回
- (CGFloat)systemVersionByFloat
{
    return [self.systemVersion floatValue];
}

// 系统版本比较
- (BOOL)systemVersionLowerThan:(NSString*)version
{
    if (version == nil || version.length == 0) {
        return NO;
    }
    
    if ([self.systemVersion compare:version options:NSNumericSearch] == NSOrderedAscending) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)systemVersionHigherThan:(NSString*)version
{
    if (version == nil || version.length == 0) {
        return NO;
    }
    
    if ([self.systemVersion compare:version options:NSNumericSearch] == NSOrderedDescending) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)systemVersionNotHigherThan:(NSString*)version
{
    if (version == nil || version.length == 0) {
        return NO;
    }
    
    if ([self.systemVersion isEqualToString:version]) {
        return YES;
    }
    else {
        return [self systemVersionLowerThan:version];
    }
}

- (BOOL)systemVersionNotLowerThan:(NSString *)version
{
    if (version == nil || version.length == 0) {
        return NO;
    }
    
    if ([self.systemVersion isEqualToString:version]) {
        return YES;
    }
    else {
        return [self systemVersionHigherThan:version];
    }
}

- (BOOL) hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale == 2.0f);
}


// Return the local MAC addy
// Courtesy of FreeBSD hackers email list

- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    //    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
    //                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return [outstring uppercaseString];
}

// 内存信息
+ (unsigned long)freeMemory{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

+ (unsigned long)usedMemory{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0;
}

- (PRK_ScreenType)screenType
{
    static PRK_ScreenType screenType = PRK_ScreenTypeUndefined;
    if (screenType == PRK_ScreenTypeUndefined) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        int height = MAX(screenBounds.size.width, screenBounds.size.height);
        int width = MIN(screenBounds.size.width, screenBounds.size.height);
        
        int scale = [[UIScreen mainScreen] scale];
        
        if (height == 480 && width == 320) {
            if (scale == 1) {
                screenType = PRK_ScreenTypeClassic;
            } else if (scale == 2){
                screenType = PRK_ScreenTypeRetina;
            }
        } else if (height == 568 && width == 320){
            screenType = PRK_ScreenType4InchRetina;
        } else if (height == 667 && width == 375){
            screenType = PRK_ScreenType6;
        } else if (height == 736 && width == 414){
            screenType = PRK_ScreenType6Plus;
        } else if (height == 1024 && width == 768) {
            if (scale == 1){
                screenType = PRK_ScreenTypeIpadClassic;
            } else if (scale == 2) {
                screenType = PRK_ScreenTypeIpadRetina;
            }
        }
    }
    return screenType;
}

- (BOOL)prk_isIPhone6Plus
{
    return [self screenType] == PRK_ScreenType6Plus;
}

- (BOOL)prk_isIPhone6
{
    return [self screenType] == PRK_ScreenType6;
}

@end
