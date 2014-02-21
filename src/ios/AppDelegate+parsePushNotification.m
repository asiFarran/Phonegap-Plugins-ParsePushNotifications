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



@implementation AppDelegate (parsePushNotification)


// The goal is to have a drop-in module that does not require the user to
// make any manual additions to the AppDelegate

// To do so we need to hook into the AppDelegate events and life cyle
// and we do so by creating a category class implementing only the functionailty relevant to this plugin

// The only way to allow SEVERAL plugins to use this method with colliding
// is to register static and unique event handlers that then use [[UIApplication sharedApplication] delegate]
// to gain access to the root controller and the actual plugin

// All variables and method names are postfixed with the plugin name to try and ensure they are unique
// to prevent collision with other plugin handlers

static NSMutableDictionary *notificationPayload_parsePushNotification;
static BOOL isColdStart_parsePushNotification;

+ (void)load
{
  
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForNotificationsOnStartup_parsePushNotification:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveHandler_parsePushNotification:)
                                                 name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}




+ (void)checkForNotificationsOnStartup_parsePushNotification:(NSNotification *)notification
{
    NSDictionary *launchOptions = [notification userInfo];
    
    if (launchOptions)
    
        notificationPayload_parsePushNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
    
        if(notificationPayload_parsePushNotification){
            
            isColdStart_parsePushNotification = YES;
        }
    
}

+ (void)applicationDidBecomeActiveHandler_parsePushNotification:(NSNotification *)notification
{
    
	AppDelegate *delegate =  [[UIApplication sharedApplication] delegate];
        
        if (![delegate.viewController.webView isLoading] && notificationPayload_parsePushNotification) {
            
            ParsePushNotificationPlugin *handler = [delegate getCommandInstance:@"ParsePushNotificationPlugin"];
            
            handler.pendingNotification = notificationPayload_parsePushNotification;
            notificationPayload_parsePushNotification = nil;
            
            // on cold start the cordova view will not be ready to handle the event yet
            // so we don tinvoke it. It will call when its ready
            if(isColdStart_parsePushNotification){
                
                isColdStart_parsePushNotification = NO; //reset flag so new incoming notifications can be passed directly to the handler
            }
            else{
                [handler performSelectorOnMainThread:@selector(notificationReceived) withObject:handler waitUntilDone:NO];
            }
        }
        
        delegate = nil;
	
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
        pushHandler.pendingNotification = notificationPayload;
        
        [pushHandler notificationReceived];
        
    } else {
        //save it for later
        notificationPayload_parsePushNotification = notificationPayload;
    }
}

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}


@end
