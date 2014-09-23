//
//  Utilities.m
//  Wheaton App
//
//  Created by Chris Anderson on 9/23/14.
//
//

#import "Utilities.h"

@implementation Utilities

+ (BOOL)enabledNotifications
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
