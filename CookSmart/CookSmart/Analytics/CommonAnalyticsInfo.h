//
//  CommonAnalyticsInfo.h
//  CookSmart
//
//  Created by Vova Galchenko on 2/6/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#ifndef CookSmart_CommonAnalyticsInfo_h
#define CookSmart_CommonAnalyticsInfo_h

#include <sys/types.h>
#include <sys/sysctl.h>

#define INSTALLATION_ID_USER_DEFAULTS_KEY       @"installation_id"

static inline NSString *userTimeZone()
{
    [NSTimeZone resetSystemTimeZone];
    return [[NSTimeZone systemTimeZone] name];
}

static inline NSString *currentLanguage()
{
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSString *primaryLanguage = @"unknown_language";
    if ([preferredLanguages count] > 0)
    {
        primaryLanguage = preferredLanguages[0];
    }
    return primaryLanguage;
}

static inline NSString *modelId()
{
    NSString *model = @"";
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    
    // check that machine was correctly allocated by malloc.
    if (machine != NULL)
    {
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    }
    
    return model;
}

static inline NSString *deviceModel()
{
    NSString *modelID = modelId();
    
    if ([modelID isEqualToString:@"iPhone1,1"]) {
        return @"iPhone";
    } else if ([modelID isEqualToString:@"iPhone1,2"]) {
        return @"iPhone 3G";
    } else if ([modelID isEqualToString:@"iPhone2,1"]) {
        return @"iPhone 3GS";
    } else if ([modelID isEqualToString:@"iPhone3,1"]) {
        return @"iPhone 4 (GSM)"; // AT&T
    } else if ([modelID isEqualToString:@"iPhone3,2"]) {
        return @"iPhone 4 (CDMA)"; // Verizon
    } else if ([modelID isEqualToString:@"iPhone3,3"]) {
        return @"iPhone 4 (CDMA 2nd Generation)"; // Verizon / Sprint
    } else if ([modelID isEqualToString:@"iPhone4,1"]) {
        return @"iPhone 4S"; // World Phone (AT&T, Verizon, and Sprint)
    } else if ([modelID isEqualToString:@"iPhone5,1"]) {
        return @"iPhone 5 (GSM)"; // With LTE. US and International.
    } else if ([modelID isEqualToString:@"iPhone5,2"]) {
        return @"iPhone 5 (CDMA)"; // With LTE
    } else if ([modelID isEqualToString:@"iPod1,1"]) {
        return @"iPod touch 1st Generation";
    } else if ([modelID isEqualToString:@"iPod2,1"]) {
        return @"iPod touch 2nd Generation";
    } else if ([modelID isEqualToString:@"iPod3,1"]) {
        return @"iPod touch 3rd Generation";
    } else if ([modelID isEqualToString:@"iPod4,1"]) {
        return @"iPod touch 4th Generation";
    } else if ([modelID isEqualToString:@"iPod5,1"]) {
        return @"iPod touch 5th Generation";
    } else if ([modelID isEqualToString:@"iPad1,1"]) {
        return @"iPad";
    } else if ([modelID isEqualToString:@"iPad2,1"]) {
        return @"iPad 2 (WiFi)";
    } else if ([modelID isEqualToString:@"iPad2,2"]) {
        return @"iPad 2 (GSM)"; // AT&T
    } else if ([modelID isEqualToString:@"iPad2,3"]) {
        return @"iPad 2 (CDMA)"; // Verizon
    } else if ([modelID isEqualToString:@"iPad2,4"]) {
        return @"iPad 2 (WiFi) Rev A";
        // Reduced price $399 iPad 2 sold alongside new (3rd and 4th gen) iPad - sold in WiFi-only or WiFi-and-3G but unclear if it's all 'iPad2,4' if if there is another model ID.
    } else if ([modelID isEqualToString:@"iPad2,5"]) {
        return @"iPad mini (WiFi)";
    } else if ([modelID isEqualToString:@"iPad2,6"]) {
        return @"iPad mini (GSM)"; // AT&T
    } else if ([modelID isEqualToString:@"iPad2,7"]) {
        return @"iPad mini (CDMA)"; // Verizon
    } else if ([modelID isEqualToString:@"iPad3,1"]) {
        return @"iPad 3rd Generation (WiFi)";
    } else if ([modelID isEqualToString:@"iPad3,2"]) {
        return @"iPad 3rd Generation (4G LTE CDMA)"; // Verizon
    } else if ([modelID isEqualToString:@"iPad3,3"]) {
        return @"iPad 3rd Generation (4G LTE)"; // AT&T
    } else if ([modelID isEqualToString:@"iPad3,4"]) {
        return @"iPad 4rd Generation (WiFi)";
    } else if ([modelID isEqualToString:@"iPad3,5"]) {
        return @"iPad 4rd Generation (4G LTE)"; // AT&T
    } else if ([modelID isEqualToString:@"iPad3,6"]) {
        return @"iPad 4rd Generation (4G LTE CDMA)"; // Verizon
    } else if ([modelID isEqualToString:@"iPad4,1"]) {
        return @"iPad Air (WiFi)";
    } else if ([modelID isEqualToString:@"iPad4,2"]) {
        return @"iPad Air (WiFi/Cellular)";
    } else if ([modelID isEqualToString:@"iPad4,4"]) {
        return @"iPad mini Retina/2nd Gen Wi-Fi";
    } else if ([modelID isEqualToString:@"iPad4,5"]) {
        return @"iPad mini Retina/2nd Gen Wi-Fi/Cellular";
    } else if ([modelID isEqualToString:@"i386"] || [modelID isEqualToString:@"x86_64"] || [modelID isEqualToString:@"x86_32"]) {
        return @"Simulator";
    } else {
        return @"Unknown";
    }
}

static inline NSString *displayResolutionString()
{
    CGSize screenSizeInPoints = [[UIScreen mainScreen] bounds].size;
    CGFloat pixelsPerPoint = [[UIScreen mainScreen] scale];
    return [NSString stringWithFormat:@"%dx%d", (int) (screenSizeInPoints.width * pixelsPerPoint), (int) (screenSizeInPoints.height * pixelsPerPoint)];
}

static inline NSString *appInstallationId()
{
    NSString *installationId = [[NSUserDefaults standardUserDefaults] objectForKey:INSTALLATION_ID_USER_DEFAULTS_KEY];
    if (!installationId.length)
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        installationId = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
        [[NSUserDefaults standardUserDefaults] setObject:installationId forKey:INSTALLATION_ID_USER_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return installationId;
}

static inline NSDictionary *commonAttributes()
{
    return @{
             @"os" : [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]],
             @"user_locale" : [[NSLocale currentLocale] localeIdentifier],
             @"user_timezone" : userTimeZone(),
             @"user_language" : currentLanguage(),
             @"app_version" : [NSString stringWithFormat:@"%@.%@",
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]],
             @"platform" : @"iOS",
             @"analytics_version" : @"1",
             @"model_id" : modelId(),
             @"device_model" : deviceModel(),
             @"display_resolution" : displayResolutionString(),
             @"display_scale" : [NSString stringWithFormat:@"%.2f", [[UIScreen mainScreen] scale]],
             @"app_name" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"],
             @"installation_id" : appInstallationId(),
             @"device_name" : [[UIDevice currentDevice] name],
             };
}

#endif
