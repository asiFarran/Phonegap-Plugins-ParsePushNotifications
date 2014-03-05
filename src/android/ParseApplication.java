package com.stratogos.cordova.parsePushNotifications;

import android.app.Application;
import com.parse.Parse;
import com.parse.ParseInstallation;
import com.parse.PushService;
import com.stratogos.cordova.parsePushNotifications.PushHandlerActivity;

public class MyApplication extends Application {

    public MyApplication(){
        super();
    }

    public void onCreate(){
        Parse.initialize(getApplicationContext(), "2BxJyqYF3WSqCZpMx5PPZqswfrrRCaqiOxHBCKYz", "SAJBghasKdav0iD66flEX8577gwr4rh52AquIHSA");
        PushService.setDefaultPushCallback(getApplicationContext(), PushHandlerActivity.class);
        ParseInstallation.getCurrentInstallation().saveInBackground();
    }
}
