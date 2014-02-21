//
//  ParsePushNotificationPlugin.m
//  HelloWorld
//
//  Created by yoyo on 2/12/14.
//
//

#import "ParsePushNotificationPlugin.h"
#import <Parse/Parse.h>

@implementation ParsePushNotificationPlugin
    
    @synthesize pendingNotification;
    @synthesize callbackId;
    @synthesize callback;
    
    
- (void)unregister:(CDVInvokedUrlCommand*)command;
    {
        self.callbackId = command.callbackId;
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [self successWithMessage:@"unregistered"];
    }
    
    - (void)register:(CDVInvokedUrlCommand*)command;
    {
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];
        
        NSString *appId = [options objectForKey:@"appId"];
        NSString *clientKey = [options objectForKey:@"clientKey"];
                
        [Parse setApplicationId:appId clientKey:clientKey];
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
        
        self.callbackId = command.callbackId;
        self.callback = [options objectForKey:@"notificationCallback"];
        
        
        if (pendingNotification)			// if there is a pending startup notification
		[self notificationReceived];	// go ahead and process it
    }
    
    
- (void)getInstallationId:(CDVInvokedUrlCommand*) command
    {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSString *objectId = currentInstallation.objectId;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:objectId];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    
- (void)getSubscriptions: (CDVInvokedUrlCommand *)command
    {
        NSArray *channels = [PFInstallation currentInstallation].channels;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:channels];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
- (void)subscribeToChannel: (CDVInvokedUrlCommand *)command
    {        
        CDVPluginResult* pluginResult = nil;
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        NSString *channel = [command.arguments objectAtIndex:0];
        [currentInstallation addUniqueObject:channel forKey:@"channels"];
        [currentInstallation saveInBackground];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
- (void)unsubscribeFromChannel: (CDVInvokedUrlCommand *)command
    {
        CDVPluginResult* pluginResult = nil;
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        NSString *channel = [command.arguments objectAtIndex:0];
        [currentInstallation removeObject:channel forKey:@"channels"];
        [currentInstallation saveInBackground];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    [results setValue:token forKey:@"deviceToken"];
    
#if !TARGET_IPHONE_SIMULATOR
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
       [self successWithMessage:[NSString stringWithFormat:@"%@", token]];
#endif
}
    
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
    {
        [self failWithMessage:@"" withError:error];
    }
    
- (void)notificationReceived {
    NSLog(@"Notification received");
    
    if (pendingNotification && self.callback)
    {
        BOOL appInForeground = [[pendingNotification objectForKey:@"appActiveWhenReceiving"] boolValue];
        NSDictionary *aps = [pendingNotification objectForKey:@"aps"];
        NSMutableDictionary *data = [[pendingNotification objectForKey:@"data"] mutableCopy];
        
        if(data == nil){
            data = [[NSMutableDictionary alloc] init];
        }
        
        /*
         
        the aps.alert value is required in order for the ios notification center to have something to show
         or else it wouls show the full JSON payload.
         
         however on the js side we want to access all the properties for this notification inside a single
         object and care not for ios specific implemenataion such as the aps wrapper
         
         we could just duplicate the text and have it in both *aps.alert* and inside data.message but as the
         payload size limit is only 256 bytes it is better to check if an explicit data.message value exists
         and if not just copy aps.alert into it
         
        */
        
        if([aps objectForKey:@"alert"]){
            if(![data objectForKey:@"message"]){
                [data setObject:[aps objectForKey:@"alert"] forKey:@"message"];
            }
        }
        
        NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
        
        [notification setObject:[NSNumber numberWithBool:appInForeground] forKey:@"receivedWhileInForeground"];
        [notification setObject:data forKey:@"data"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:notification options:NSJSONWritingPrettyPrinted error:nil];
                            
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        NSLog(@"Msg: %@", json);
        
        NSString * jsCallBack = [NSString stringWithFormat:@"%@(%@);", self.callback, json];
        [self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
        
        self.pendingNotification = nil;
    }
}

    
-(void)successWithMessage:(NSString *)message
    {
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
        
        [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
    }
    
-(void)failWithMessage:(NSString *)message withError:(NSError *)error
    {
        NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        
        [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
    }
    
    @end
