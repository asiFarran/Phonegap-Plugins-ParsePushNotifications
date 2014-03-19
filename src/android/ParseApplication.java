package com.stratogos.cordova.parsePushNotifications;

import android.app.Application;
import com.parse.Parse;
import com.parse.ParseInstallation;
import com.parse.PushService;

public class ParseApplication extends Application {

    public ParseApplication(){
        super();
    }

    public void onCreate(){
        Parse.initialize(getApplicationContext(), "appId", "clientKey");
        PushService.setDefaultPushCallback(getApplicationContext(), PushHandlerActivity.class);
        ParseInstallation.getCurrentInstallation().saveInBackground();
    }
}
