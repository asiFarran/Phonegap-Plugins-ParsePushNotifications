package com.stratogos.cordova.parsePushNotifications;

import com.google.android.gcm.GCMBaseIntentService;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

@SuppressLint("NewApi")
public class GCMIntentService extends GCMBaseIntentService {

    private static final String TAG = "GCMIntentService";

    public GCMIntentService() {
        super("GCMIntentService");
    }

    @Override
    public void onRegistered(Context context, String regId) {
        // do nothing - the parse receiver takes care of registrations
    }

    @Override
    public void onUnregistered(Context context, String regId) {
        // do nothing - the parse receiver takes care of registrations
    }

    @Override
    protected void onMessage(Context context, Intent intent) {
        Log.d(TAG, "onMessage - context: " + context);

        //do nothing with notifications arriving while we are not focused. we'll respond to them in the activity that gets the user click
        if(ParsePushNotificationPlugin.isInForeground()){
            ParsePushNotificationPlugin.NotificationReceived(intent.getExtras().getString("data"), true);
        }
    }


    @Override
    public void onError(Context context, String errorId) {
        Log.e(TAG, "onError - errorId: " + errorId);
    }

}
