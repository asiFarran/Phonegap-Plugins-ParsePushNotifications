//
//  AppDelegate+parsePushNotification.m
//  HelloWorld
//
//  Created by yoyo on 2/12/14.
//
//

#import "AppDelegate+parsePushNotification.h"

#import "ParsePushNotificationPlugin.h"
#import <objc/runtime.h>
#import <Parse/Parse.h>

static NSMutableDictionary *remoteNotification;
static BOOL remoteNotificationColdStart;

@implementation AppDelegate (parsePushNotification)



- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

+ (void)load
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForRemoteNotificationOnStartup:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}




- (void)checkForRemoteNotificationOnStartup:(NSNotification *)notification
{
    if (notification)
    {
        NSDictionary *launchOptions = [notification userInfo];
        if (launchOptions)
        remoteNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if(remoteNotification){
            remoteNotificationColdStart = YES;
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
    [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveNotification");
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    NSMutableDictionary *notificationPayload = [userInfo mutableCopy];
    [notificationPayload setObject:[NSNumber numberWithBool:(appState == UIApplicationStateActive)] forKey:@"appActiveWhenReceiving"];
    
    if (appState == UIApplicationStateActive) {
        ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
        pushHandler.notificationMessage = notificationPayload;
        [pushHandler notificationReceived];
    } else {
        //save it for later
        remoteNotification = notificationPayload;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
   NSLog(@"push notification active");
    

    
    if (![self.viewController.webView isLoading] && remoteNotification) {
        ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
        
        pushHandler.notificationMessage = remoteNotification;
        remoteNotification = nil;
		
		if(remoteNotificationColdStart){
            remoteNotificationColdStart = NO; //reset flag so new incoming notifications can be passed directly to the handler
        }
        else{
            [pushHandler performSelectorOnMainThread:@selector(notificationReceived) withObject:pushHandler waitUntilDone:NO];
        }
        
    }
}


@end
