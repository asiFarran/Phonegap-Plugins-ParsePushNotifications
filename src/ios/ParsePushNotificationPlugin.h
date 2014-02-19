//
//  ParsePushNotificationPlugin.h
//  HelloWorld
//
//  Created by yoyo on 2/12/14.
//
//

#import <Cordova/CDV.h>

@interface ParsePushNotificationPlugin : CDVPlugin
    {
        NSDictionary *notificationMessage;
        BOOL    isInForeground;
        NSString *notificationCallbackId;
        NSString *callback;
        
        BOOL ready;
    }
    
    @property (nonatomic, copy) NSString *callbackId;
    @property (nonatomic, copy) NSString *notificationCallbackId;
    @property (nonatomic, copy) NSString *callback;

    
    @property (nonatomic, strong) NSDictionary *notificationMessage;
    
- (void)register:(CDVInvokedUrlCommand*)command;
    - (void)unregister:(CDVInvokedUrlCommand*)command;
    - (void)getInstallationId:(CDVInvokedUrlCommand*)command;

    - (void)getSubscriptions:(CDVInvokedUrlCommand*)command;
        - (void)subscribeToChannel:(CDVInvokedUrlCommand*)command;
        - (void)unsubscribeFromChannel:(CDVInvokedUrlCommand*)command;
    
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
    
- (void)setNotificationMessage:(NSDictionary *)notification;
- (void)notificationReceived;
    
@end
