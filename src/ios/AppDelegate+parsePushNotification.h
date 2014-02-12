//
//  AppDelegate+parsePushNotification.h
//

#import "AppDelegate.h"


@interface AppDelegate (parsePushNotification)
    
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (id) getCommandInstance:(NSString*)className;
    
    @property (nonatomic, retain) NSDictionary	*launchNotification;
    
@end
