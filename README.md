Phonegap-Plugins-ParsePushNotifications
=======================================
> receive push message from Parse.com in your phonegap app  


## Installation:

    phonegap local plugin add https://github.com/asiFarran/Phonegap-Plugins-ParsePushNotifications.git
    
On iOS the plugin uses method swizzling on AppDelegate to hook into the app lifecyle and avoid making manual changes to the main AppDelegate code. This solution has been adopted from the code for the <a target='_blank' href='https://github.com/phonegap-build/PushPlugin'>PushNotification plugin </a>

## Usage:

The plugin creates the object window.plugins.parsePushNotifications

    
To register for notifications: 
	    
    window.plugins.parsePushNotifications.register({
       appId: "your-app-id",
       clientKey: "your-client-key",
       onNotification: 'your-callback-handler'
    });
	
**Please note** that in order to support cold start scenarios the notification callback must be reachable from the global scope!


I've just commited this here for my own trials so no other docs for the moment... coming soon
