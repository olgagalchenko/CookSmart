//
//  AnalyticsSender.h
//  CookSmart
//
//  Created by Vova Galchenko on 2/6/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsSender : NSObject

+ (AnalyticsSender *)sharedInstance;
- (void)sendFlushedAnalytics;

@end
