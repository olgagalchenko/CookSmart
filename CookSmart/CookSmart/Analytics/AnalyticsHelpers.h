//
//  AnalyticsHelpers.h
//  CookSmart
//
//  Created by Vova Galchenko on 2/6/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#ifndef CookSmart_AnalyticsHelpers_h
#define CookSmart_AnalyticsHelpers_h

#define ANALYTICS_ROUGH_LOG_FILE_SIZE_CAP       (1<<20) // 1 MB

static inline NSString *rootAnalyticsDirectoryPath()
{
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [[documentsDirectory path] stringByAppendingPathComponent:@"analytics"];
}

static inline NSString *currentLogFilePath()
{
    return [rootAnalyticsDirectoryPath() stringByAppendingPathComponent:@"current_log"];
}

static inline NSString *logsToSendDirectoryPath()
{
    return [rootAnalyticsDirectoryPath() stringByAppendingPathComponent:@"logs_to_send"];
}

static inline NSString *zippedAnalyticsFilePath()
{
    return [rootAnalyticsDirectoryPath() stringByAppendingPathComponent:@"zipped_logs"];
}

static inline NSURL *analyticsPostURL()
{
    return [NSURL URLWithString:@"http://asswaffle.com/api/analytics.py"];
}

#endif
