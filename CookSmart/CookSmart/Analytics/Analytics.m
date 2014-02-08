//
//  Analytics.m
//  CookSmart
//
//  Created by Vova Galchenko on 2/6/14.
//  Copyright (c) 2014 Olga Galchenko. All rights reserved.
//

#import "Analytics.h"
#import "AnalyticsWriter.h"
#import "AnalyticsSender.h"

#define ANALYTICS_SESSION_ID_USER_DEFAULTS_KEY                      @"analytics_session_id"
#define ANALYTICS_DATE_OF_FIRST_EVENT_IN_SESSION_USER_DEFAULTS_KEY  @"analytics_first_date_in_session"
#define ANALYTICS_DATE_OF_LAST_EVENT_IN_SESSION_USER_DEFAULTS_KEY   @"analytics_last_date_in_session"
#define ANALYTICS_FIRST_SESSION_ID                                  @1
#define ANALYTICS_MAX_IDLE_TIME_IN_SESSION                          (30*60)

#define ANALYTICS_EVENT_NAME_KEY                                    @"event_name"
#define ANALYTICS_EVENT_TYPE_KEY                                    @"event_type"



@interface Analytics()

@property (nonatomic, readwrite, strong) NSNumber *sessionId;
@property (nonatomic, readwrite, strong) NSDate *dateOfFirstEventInSession;
@property (nonatomic, readwrite, strong) NSDate *dateOfLastEventInSession;

@end

@implementation Analytics

static Analytics *sharedInstance = nil;

#pragma mark - Singleton Management

+ (Analytics *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

static inline NSDate *getSpecialDateOrCurrent(NSString *specialDateUserDefaultsKey)
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:specialDateUserDefaultsKey];
    if (!date)
    {
        date = [NSDate date];
    }
    return date;
}

- (id)init
{
    NSAssert(!sharedInstance, @"Never create an instance of Analytics directly. Use the singleton.");
    if ((self = [super init]))
    {
        self.sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:ANALYTICS_SESSION_ID_USER_DEFAULTS_KEY];
        if (!self.sessionId)
        {
            self.sessionId = @1;
        }
        self.dateOfFirstEventInSession = getSpecialDateOrCurrent(ANALYTICS_DATE_OF_FIRST_EVENT_IN_SESSION_USER_DEFAULTS_KEY);
        self.dateOfLastEventInSession = getSpecialDateOrCurrent(ANALYTICS_DATE_OF_LAST_EVENT_IN_SESSION_USER_DEFAULTS_KEY);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDidEnterBackgroundNotification)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

#pragma - Public Interface Implementation

- (void)logEventWithName:(NSString *)eventName
                    type:(AnalyticsEventType)eventType
              attributes:(NSDictionary *)attributes
{
    NSAssert(eventName.length, @"Each analytics event must have a name.");
    [self addNewEventToSession];
    
    NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [eventDictionary setObject:eventName forKey:ANALYTICS_EVENT_NAME_KEY];
    [eventDictionary setObject:eventTypeStringForEventType(eventType) forKey:ANALYTICS_EVENT_TYPE_KEY];
    [self write:eventDictionary];
}

- (void)sendAnalytics
{
    [[AnalyticsWriter sharedInstance] flushCurrentLogFile];
    [[AnalyticsSender sharedInstance] sendFlushedAnalytics];
}

#pragma mark - Session Management

- (void)addNewEventToSession
{
    @synchronized(self)
    {
        NSDate *newLastEventInSession = [NSDate date];
        if ([newLastEventInSession timeIntervalSinceDate:self.dateOfLastEventInSession] > ANALYTICS_MAX_IDLE_TIME_IN_SESSION)
        {
            // This session has ended
            NSTimeInterval sessionDuration = [self.dateOfLastEventInSession timeIntervalSinceDate:self.dateOfFirstEventInSession];
            if (sessionDuration)
            {
                // Write the end of the session
                NSDictionary *sessionInfo = @{
                                              ANALYTICS_EVENT_NAME_KEY : @"session_end",
                                              ANALYTICS_EVENT_TYPE_KEY : eventTypeStringForEventType(AnalyticsEventTypeAppLifecycle),
                                              @"duration" : [NSNumber numberWithDouble:sessionDuration],
                                              };
                [self write:sessionInfo];
            }
            self.dateOfFirstEventInSession = newLastEventInSession;
            self.dateOfLastEventInSession = newLastEventInSession;
            self.sessionId = [NSNumber numberWithUnsignedLongLong:[self.sessionId unsignedLongLongValue] + 1];
            [self persistSessionInformation];
        }
    }
}

- (void)persistSessionInformation
{
    NSAssert(self.sessionId && self.dateOfLastEventInSession && self.dateOfFirstEventInSession,
             @"Attempting to persist analytics session information without having created it.");
    [[NSUserDefaults standardUserDefaults] setObject:self.sessionId forKey:ANALYTICS_SESSION_ID_USER_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.dateOfFirstEventInSession forKey:ANALYTICS_DATE_OF_FIRST_EVENT_IN_SESSION_USER_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.dateOfLastEventInSession forKey:ANALYTICS_DATE_OF_LAST_EVENT_IN_SESSION_USER_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Event Handling

- (void)handleDidEnterBackgroundNotification
{
    [self persistSessionInformation];
    [self sendAnalytics];
}

#pragma mark - Writing To Local Files

- (void)write:(NSDictionary *)eventDictionary
{
    NSMutableDictionary *finalDictionary = [NSMutableDictionary dictionaryWithDictionary:eventDictionary];
    [finalDictionary setObject:[NSNumber numberWithInteger:(NSInteger)[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [[AnalyticsWriter sharedInstance] write:finalDictionary];
}

#pragma mark - Misc Helpers

static inline NSString *eventTypeStringForEventType(AnalyticsEventType eventType)
{
    NSString *eventTypeString = @"unknown_event_type";
    switch (eventType)
    {
        case AnalyticsEventTypeAppLifecycle:
            eventTypeString = @"app_lifecycle";
            break;
        case AnalyticsEventTypeCrash:
            eventTypeString = @"crash";
            break;
        case AnalyticsEventTypeDebug:
            eventTypeString = @"debug";
            break;
        case AnalyticsEventTypeIssue:
            eventTypeString = @"issue";
            break;
        case AnalyticsEventTypeUserAction:
            eventTypeString = @"user_action";
            break;
        case AnalyticsEventTypeViewChange:
            eventTypeString = @"view_change";
            break;
        default:
            NSCAssert(NO, @"Unknown event type.");
            break;
    }
    return eventTypeString;
}

@end
