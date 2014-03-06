package com.stratogos.cordova.parsePushNotifications;

import java.util.Set;

import java.util.ArrayList;
import com.parse.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;


public class ParsePushNotificationPlugin extends CordovaPlugin {
    public static final String TAG = "ParsePushNotificationPlugin";

    private static CordovaWebView gWebView;

    private static boolean isInForeground = false;
    private static boolean canDeliverNotifications = false;
    private static ArrayList<String> callbackQueue = new ArrayList<String>();

    /**
     * Gets the application context from cordova's main activity.
     * @return the application context
     */
    private Context getApplicationContext() {
        return this.cordova.getActivity().getApplicationContext();
    }

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        Log.v(TAG, "execute: action=" + action);

        if (action.equalsIgnoreCase("register")){

            //JSONObject params = args.optJSONObject(0);

            // Parse.initialize(getApplicationContext(), params.optString("appId",""), params.optString("clientKey", ""));
            // PushService.setDefaultPushCallback(getApplicationContext() ,PushHandlerActivity.class);
            // ParseInstallation.getCurrentInstallation().saveInBackground();

            callbackContext.success();

            canDeliverNotifications = true;

            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    flushCallbackQueue();
                }
            });


            return true;
        }
        else if (action.equalsIgnoreCase("unregister")){

            ParseInstallation.getCurrentInstallation().deleteInBackground();

            callbackContext.success();

            return true;
        }
        else if (action.equalsIgnoreCase("getInstallationId")){

            // no installation tokens on android
            callbackContext.success();

            return true;
        }
        else if (action.equalsIgnoreCase("getSubscriptions")){

            Set<String> channels = PushService.getSubscriptions(getApplicationContext());

            JSONArray subscriptions = new JSONArray();

            for(String c:channels){
                subscriptions.put(c);
            }

            callbackContext.success(subscriptions);

            return true;
        }
        else if (action.equalsIgnoreCase("subscribeToChannel")){

            String channel = args.optString(0);

            PushService.subscribe(getApplicationContext(),channel, PushHandlerActivity.class);

            callbackContext.success();

            return true;
        }
        else if (action.equalsIgnoreCase("unsubscribeFromChannel")){

            String channel = args.optString(0);

            PushService.unsubscribe(getApplicationContext(), channel);

            callbackContext.success();

            return true;
        }

        return false;
    }

    /*
     * Sends a json object to the client as parameter to a method which is defined in gECB.
     */
    public static void NotificationReceived(String json, boolean receivedInForeground) {

        String state = receivedInForeground ? "foreground" : "background";

        Log.v(TAG, "state: " + state + ", json:" + json);


        /*

         THE following is the comment from the iOS version explaining the motivation for copying the 'alert'
         files into data.message in case there is no explicit one set.

         on Android this isn't really needed but we keep it so the behavior is identical on both platforms.

         -------------------

         on iOS we must have the alert field set on the wrapping aps hash. in addition as we have severe
         limitation on the size of the payload we would normally avoid duplicating the notification text
         in both the aps wrapper and the payload object itself.

         in order to keep the interface identical between platforms
         the aps.alert value is required in order for the ios notification center to have something to show
         or else it wouls show the full JSON payload.

         however on the js side we want to access all the properties for this notification inside a single
         object and care not for ios specific implemenataion such as the aps wrapper

         we could just duplicate the text and have it in both *aps.alert* and inside data.message but as the
         payload size limit is only 256 bytes it is better to check if an explicit data.message value exists
         and if not just copy aps.alert into it

         */

        try
        {
            JSONObject wrapper = new JSONObject(json);
            JSONObject data = wrapper.getJSONObject("data");

            if(data != null){
                if(data.has("message") == false){
                    if(wrapper.has("alert")){
                        data.put("message", wrapper.getString("alert"));
                    }
                }
            }

            json = data.toString();

        }catch(JSONException e){}

        String js = "javascript:setTimeout(function(){window.plugin.parse_push.ontrigger('" + state + "',"+ json +")},0)";

        if (canDeliverNotifications) {
            gWebView.sendJavascript(js);
        }else{
            callbackQueue.add(js);
        }

    }


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        gWebView = webView;
        isInForeground = true;
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        gWebView = null;
        isInForeground = false;
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        isInForeground = false;
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        isInForeground = true;
    }

    private void flushCallbackQueue(){
        for(String js : callbackQueue){
            gWebView.sendJavascript(js);
        }

        callbackQueue.clear();
    }

    public static boolean isActive()
    {
        return gWebView != null;
    }

    public static boolean isInForeground()
    {
        return isInForeground;
    }
}
