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

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
    [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)payload
{
    
    NSLog(@"didReceiveRemoteNotification");
    UIApplicationState appstate = [[UIApplication sharedApplication] applicationState];
    
    
    NSMutableDictionary *extendedPayload = [payload mutableCopy];
    [extendedPayload setObject:[NSNumber numberWithBool:(appstate == UIApplicationStateActive)] forKey:@"receivedInForeground"];
    
    ParsePushNotificationPlugin *pushHandler = [self getCommandInstance:@"ParsePushNotificationPlugin"];
    [pushHandler didReceiveRemoteNotificationWithPayload:extendedPayload];
}

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}


@end