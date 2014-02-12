cordova.define("com.stratogos.cordova.parsePushNotifications", function(require, exports, module) {
               
               var exec = require('cordova/exec');
               var pluginNativeName = "ParsePushNotificationPlugin";
               
               var ParsePushPlugin = function () {};
               
               
               ParsePushPlugin.prototype.register = function(options, successCallback, errorCallback) {
               
                    exec(
                            successCallback,
                            errorCallback,
                            pluginNativeName,
                            'register',
                            [options]);
               };
               
               ParsePushPlugin.prototype.getInstallationId = function(successCallback, errorCallback) {
               
                    exec(
                            successCallback,
                            errorCallback,
                            pluginNativeName,
                            'getInstallationId',
                            []);
               };
               
               ParsePushPlugin.prototype.getSubscriptions = function(successCallback, errorCallback) {
               
                    exec(
                            successCallback,
                            errorCallback,
                            pluginNativeName,
                            'getSubscriptions',
                            []);
               };
               
               ParsePushPlugin.prototype.subscribe = function(channel, successCallback, errorCallback) {
               
                    exec(
                            successCallback,
                            errorCallback,
                            pluginNativeName,
                            'subscribeToChannel',
                            [ channel ]);
               };
               
               ParsePushPlugin.prototype.unsubscribe = function(channel, successCallback, errorCallback) {
            
                    exec(
                            successCallback,
                            errorCallback,
                            pluginNativeName,
                            'unsubscribeFromChannel',
                            [ channel ]);
               };
			   
               module.exports = new ParsePushPlugin();
});

