//
//  AppDelegate+parsePushNotification.h
//  HelloWorld
//
//  Created by yoyo on 2/12/14.
//
//

#import "AppDelegate.h"


@interface AppDelegate (parsePushNotification)
    
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (id) getCommandInstance:(NSString*)className;

    
@end
