	var exec = require('cordova/exec');
    var pluginNativeName = "ParsePushNotificationPlugin";
               
    var ParsePushPlugin = function () {
    };

               
    ParsePushPlugin.prototype = {
    	
		register : function(options, successCallback, errorCallback) {
           
			exec(successCallback,errorCallback,pluginNativeName,'register',[options]);
		},
		
		getInstallationId : function(successCallback, errorCallback) {
               
			exec(successCallback,errorCallback,pluginNativeName,'getInstallationId',[]);
		},
		
		getSubscriptions : function(successCallback, errorCallback) {
               
			exec(successCallback,errorCallback,pluginNativeName,'getSubscriptions',[]);
		},
		
		subscribe : function(channel, successCallback, errorCallback) {
               
			exec(successCallback,errorCallback,pluginNativeName,'subscribeToChannel',[channel]);
		},
		
		unsubscribe : function(channel, successCallback, errorCallback) {
               
			exec(successCallback,errorCallback,pluginNativeName,'unsubscribeFromChannel',[channel]);
		},
		
               ontrigger : function(state, json){}
    };
	
               
    module.exports = new ParsePushPlugin();


