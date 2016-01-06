//
//  AppDelegate.h
//  Wheaton App
//
//  Created by Chris Anderson on 3/13/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Wheaton_App-Swift.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, MixpanelDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Mixpanel *mixpanel;

void uncaughtExceptionHandler(NSException *exception);

@end
