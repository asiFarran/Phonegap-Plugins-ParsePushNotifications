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

static UILocalNotification *launchNotification;
static BOOL notificationColdStart;

@implementation AppDelegate (parsePushNotification)
   
- (id) getCommandInstance:(NSString*)className
    {
        return [self.viewController getCommandInstance:className];
    }
    
+ (void)load
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForNotification:)
	                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}
    

    
    // This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
    // to process notifications in cold-start situations
- (void)checkForNotification:(NSNotification *)notification
    {
        if (notification)
        {
            NSDictionary *launchOptions = [notification userInfo];
            if (launchOptions)
			launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
			notificationColdStart = YES;
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
        launchNotification = notificationPayload;
    }
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"active");
    
    //zero badge
    application.applicationIconBadgeNumber = 0;
    
    if (![self.viewController.webView isLoading] && launchNotification) {
        ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
        
        pushHandler.notificationMessage = launchNotification;
        launchNotification = nil;
		
		if(notificationColdStart){
		            notificationColdStart = NO; //reset flag so new incoming notifications can be passed directly to the handler
		        }
		        else{
		             [pushHandler performSelectorOnMainThread:@selector(notificationReceived) withObject:pushHandler waitUntilDone:NO];
		        }
       
    }
}
   
    
- (void)dealloc
    {
        launchNotification	= nil; 
    }
    
    @end
