package com.kavalok.remoting
{
	public class RemoteConnection
	{
		public static const CONNECTION_URL_FORMAT : String = "rtmp://{0}";

		private static var _instance : RemoteConnectionInstance;
		
		public static function get instance() : RemoteConnectionInstance
		{
			if(_instance == null)
			{
				_instance = new RemoteConnectionInstance();
			}
			return _instance;
		}
		
		
	}
}
	import com.kavalok.Global;
	import com.kavalok.dialogs.Dialogs;
	import com.kavalok.errors.IllegalStateError;
	import com.kavalok.events.EventSender;
	import com.kavalok.location.LocationBase;
	import com.kavalok.remoting.BaseRed5Delegate;
	import com.kavalok.remoting.RemoteCommand;
	import com.kavalok.remoting.commands.ServerCommandBase;
	import com.kavalok.remoting.constants.NetConnectionCodes;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.Timers;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
internal class RemoteConnectionInstance 
{
	
	private var _error : EventSender = new EventSender();
	private var _connectEvent : EventSender = new EventSender();
	private var _disconnectEvent : EventSender = new EventSender();
	private var _forceDisconnectEvent : EventSender = new EventSender();
	
	private var _netConnection : NetConnection;
	private var _connected : Boolean;
	private var _isAdmin : Boolean = false;
	
	public function RemoteConnectionInstance()
	{
		super();
	}
	
	public function get isAdmin():Boolean
	{
		 return _isAdmin;
	}
	
	public function set isAdmin(value:Boolean):void
	{
		 _isAdmin = value;
	}
	
	public function get serverName():String
	{
		 return _netConnection.uri;
	}
	
	public function get error() : EventSender
	{
		return _error;
	}

	public function get connectEvent() : EventSender
	{
		return _connectEvent;
	}
	
	public function get disconnectEvent() : EventSender
	{
		return _disconnectEvent;
	}
	
	public function get forceDisconnectEvent() : EventSender
	{
		return _forceDisconnectEvent;
	}
	
	public function get connected() : Boolean
	{
		return _connected;
	}
	
	public function get netConnection() : NetConnection
	{
		if(_netConnection == null)
		{
			trace("RemoteConnection: Creating new NetConnection");
			_netConnection = BaseRed5Delegate.netConnection;
	        _netConnection.objectEncoding = ObjectEncoding.AMF0;
	        trace("RemoteConnection: NetConnection objectEncoding set to AMF0");
	        _netConnection.addEventListener( NetStatusEvent.NET_STATUS , onNetStatus);
	        trace("RemoteConnection: NetStatusEvent listener added");
	        _netConnection.client = this;
	        trace("RemoteConnection: NetConnection client set");
		} else {
			trace("RemoteConnection: Using existing NetConnection");
		}
		return _netConnection;
	}
	
	public function disconnect() : void
	{
		_connected = false;
		netConnection.close();
		disconnectEvent.sendEvent();
	}
	
	public function connect() : void
	{
		trace("RemoteConnection: connect() called");
		trace("RemoteConnection: connecting to: " + BaseRed5Delegate.defaultConnectionUrl);
		trace("RemoteConnection: NetConnection object: " + netConnection);
		trace("RemoteConnection: NetConnection connected: " + netConnection.connected);
		trace("RemoteConnection: NetConnection uri: " + netConnection.uri);
		
		// Add connection timeout check
		var timeoutTimer:Timer = new Timer(10000, 1); // 10 second timeout
		timeoutTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			trace("RemoteConnection: Connection timeout - no response after 10 seconds");
			trace("RemoteConnection: This might indicate RTMPS protocol issues or server not responding");
			trace("RemoteConnection: Checking if server is reachable...");
			
			// Test basic network connectivity to the server
			testServerConnectivity();
			
			if (!_connected) {
				trace("RemoteConnection: Connection still not established, sending NetStatusEvent");
				// Create a NetStatusEvent instead of a generic Event
				var timeoutEvent:NetStatusEvent = new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, {
					code: "NetConnection.Connect.Failed",
					level: "error",
					description: "Connection timeout - no response from server"
				});
				error.sendEvent(timeoutEvent);
			}
		});
		timeoutTimer.start();
		
		try {
			netConnection.connect(BaseRed5Delegate.defaultConnectionUrl);
			trace("RemoteConnection: connect() call completed successfully");
		} catch (error:Error) {
			trace("RemoteConnection: connect() error: " + error.message);
			trace("RemoteConnection: connect() error stack: " + error.getStackTrace());
			timeoutTimer.stop();
		}
	}
	
	public function onCommandInstance(properties:Object):void
	{
		RemoteCommand.createInstance(properties).execute();
	}
		
	public function onDisableChatAdmin(reason : String, enabledByMod : Boolean, enabledByParent : Boolean) : void
	{
		Dialogs.showOkDialog(
			Strings.substitute(Global.resourceBundles.kavalok.messages.badWord, reason));
			
		Global.charManager.chatEnabledByParent = !enabledByParent;
		Global.charManager.chatEnabledByMod = !enabledByMod;
			
		Global.notifications.chatEnabled = false;
	}	

	public function lc(senderId : int, senderLogin : String, message : Object) : void
	{
		Global.notifications.receiveChat(senderLogin, senderId, message);
	}

	public function loadStuff(stuffs : Array) : void
	{
		trace("Adding stuffs portion: "+stuffs);
		Global.charManager.stuffs.addToList(stuffs);
	}
	public function loadStuffEnd(stuffs : int) : void
	{
		trace("Load end. Stuffs count: "+stuffs);
	}
	

	public function lm(senderId : int, senderLogin : String, x : int, y : int, petBusy : Boolean, timestamp : int) : void
	{
		var location : LocationBase = Global.locationManager.location;
		if(location != null )
			location.moveCharServiceCall(senderLogin, x, y, petBusy, timestamp);
	}

	public function onDisableChat(reason : String, intervalToBan : uint = 0, minutesToShow : int = -1) : void
	{
		if(intervalToBan>0){
			if(minutesToShow>60)
				Dialogs.showOkDialog(Strings.substitute(
					Global.resourceBundles.kavalok.messages.badWordWithIntervalHours, reason, minutesToShow/60));
			else
   			    Dialogs.showOkDialog(Strings.substitute(
   			    	Global.resourceBundles.kavalok.messages.badWordWithInterval, reason, minutesToShow));

			Global.notifications.chatEnabled = false;
			Global.charManager.baned = true;
			Timers.callAfter(enableChat, intervalToBan);
		}
	}
	
	public function enableChat() : void{
		Global.charManager.baned = false;
		if(Global.charManager.canHaveTextChat)
			Global.notifications.chatEnabled = true;
	}
	
	public function onSkipChat(reason : String, message : String) : void
	{
		Global.notifications.receiveChat(Global.charManager.charId, Global.charManager.userId, message);
		//Ticket #3548
		//Dialogs.showOkDialog(Strings.substitute(Global.resourceBundles.kavalok.messages.skipWord, reason));
	}
	
	public function onCommand(className:String, parameter:Object = null):void
	{
		var fullName:String = 'com.kavalok.remoting.commands::' + className;
		
		if (!isAdmin && ApplicationDomain.currentDomain.hasDefinition(fullName))
		{
			var commandClass:Class = getDefinitionByName(fullName) as Class;
			var command:ServerCommandBase = new commandClass();
			command.parameter = parameter; 
			command.execute();
		}
	}
	
	private function onNetStatus(event : NetStatusEvent) : void
	{
		trace("RemoteConnection: onNetStatus() called");
		trace("RemoteConnection: NetStatusEvent info: " + event.info);
		trace("RemoteConnection: NetStatusEvent code: " + event.info.code);
		trace("RemoteConnection: NetStatusEvent level: " + event.info.level);
		trace("RemoteConnection: NetStatusEvent description: " + event.info.description);
		
		// Add additional debugging for RTMPS issues
		if (event.info.code == "NetConnection.Connect.Failed") {
			trace("RemoteConnection: RTMPS connection failed - this might be a protocol support issue");
			trace("RemoteConnection: Check if Flash Player supports RTMPS or if server is configured for RTMPS");
			trace("RemoteConnection: Connection URL was: " + BaseRed5Delegate.defaultConnectionUrl);
			trace("RemoteConnection: Flash Player version: " + flash.system.Capabilities.version);
			trace("RemoteConnection: Flash Player OS: " + flash.system.Capabilities.os);
			
			// Check if this is likely a Flash Player RTMPS limitation
			if (BaseRed5Delegate.defaultConnectionUrl.indexOf("rtmps://") == 0) {
				trace("RemoteConnection: WARNING - Flash Player has very limited RTMPS support");
				trace("RemoteConnection: RTMPS support varies by Flash Player version and platform");
				trace("RemoteConnection: Consider using RTMP with a secure tunnel (stunnel/nginx) instead");
			}
		}
		
		switch(event.info.code)
		{
			case NetConnectionCodes.SUCCESS:
				trace("RemoteConnection: Connection SUCCESS");
				setConnected();
				break;
			case NetConnectionCodes.CLOSED:
				trace("RemoteConnection: Connection CLOSED");
				setDisconnected();
				break;
			case NetConnectionCodes.APP_SHUTDOWN:
				trace("RemoteConnection: Connection APP_SHUTDOWN");
				setDisconnected();
				break;
			case NetConnectionCodes.REJECT:
				trace("RemoteConnection: Connection REJECTED");
				error.sendEvent(event);
				break;
			case NetConnectionCodes.FAILED:
				trace("RemoteConnection: Connection FAILED");
				error.sendEvent(event);
				break;
			case NetConnectionCodes.INVALID_APP:
				trace("RemoteConnection: Connection INVALID_APP");
				error.sendEvent(event);
				break;
			default:
				trace("RemoteConnection: Unknown connection code: " + event.info.code);
				throw new IllegalStateError();
				break;
		}
	}
	
	private function setDisconnected() : void
	{
		trace("RemoteConnection: setDisconnected() called");
		trace("RemoteConnection: current connected state: " + connected);
		
		if(connected)
		{
			trace("RemoteConnection: setting connected to false");
			_connected = false;
			forceDisconnectEvent.sendEvent();
			disconnectEvent.sendEvent();
			trace("RemoteConnection: disconnect events sent");
		} else {
			trace("RemoteConnection: already disconnected, no action taken");
		}
	}

	private function setConnected() : void
	{
		trace("RemoteConnection: setConnected() called");
		trace("RemoteConnection: current connected state: " + connected);
		
		_connected = true;
		connectEvent.sendEvent();
		trace("RemoteConnection: connected set to true, connect event sent");
	}
	
	private function testServerConnectivity() : void
	{
		trace("RemoteConnection: Testing server connectivity...");
		
		// Extract hostname from the connection URL
		var url:String = BaseRed5Delegate.defaultConnectionUrl;
		var hostname:String = "";
		
		if (url.indexOf("rtmps://") == 0) {
			hostname = url.substring(8); // Remove "rtmps://"
		} else if (url.indexOf("rtmp://") == 0) {
			hostname = url.substring(7); // Remove "rtmp://"
		}
		
		// Remove port and path
		var slashIndex:int = hostname.indexOf("/");
		if (slashIndex != -1) {
			hostname = hostname.substring(0, slashIndex);
		}
		
		// Remove port number
		var colonIndex:int = hostname.indexOf(":");
		if (colonIndex != -1) {
			hostname = hostname.substring(0, colonIndex);
		}
		
		trace("RemoteConnection: Extracted hostname: " + hostname);
		
		// Test HTTP connectivity to the server
		var testUrl:String = "http://" + hostname + "/";
		trace("RemoteConnection: Testing HTTP connectivity to: " + testUrl);
		
		// Also test the RTMPS hostname specifically
		var rtmpsHostname:String = "rtmps." + hostname;
		var rtmpsTestUrl:String = "http://" + rtmpsHostname + "/";
		trace("RemoteConnection: Testing RTMPS hostname connectivity to: " + rtmpsTestUrl);
		
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, function(e:Event):void {
			trace("RemoteConnection: HTTP connectivity test SUCCESS - server is reachable");
			trace("RemoteConnection: This suggests the issue is with RTMPS protocol, not network connectivity");
		});
		loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
			trace("RemoteConnection: HTTP connectivity test FAILED - server may not be reachable");
			trace("RemoteConnection: Error: " + e.text);
		});
		
		// Test RTMPS hostname connectivity
		var rtmpsLoader:URLLoader = new URLLoader();
		rtmpsLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
			trace("RemoteConnection: RTMPS hostname HTTP test SUCCESS - rtmps subdomain is reachable");
		});
		rtmpsLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
			trace("RemoteConnection: RTMPS hostname HTTP test FAILED - rtmps subdomain may not exist");
			trace("RemoteConnection: Error: " + e.text);
		});
		
		try {
			loader.load(new URLRequest(testUrl));
			rtmpsLoader.load(new URLRequest(rtmpsTestUrl));
		} catch (error:Error) {
			trace("RemoteConnection: HTTP connectivity test error: " + error.message);
		}
		
		// Also test if the RTMPS port is open (this is limited but might help)
		trace("RemoteConnection: Note: RTMPS port testing is limited in Flash Player");
		trace("RemoteConnection: RTMPS typically uses port 443 or 8443");
		trace("RemoteConnection: Server should be configured to accept RTMPS connections");
		
		// Check if the server is configured for RTMPS
		var rtmpsUrl:String = BaseRed5Delegate.defaultConnectionUrl;
		if (rtmpsUrl.indexOf("rtmps://") == 0) {
			trace("RemoteConnection: RTMPS URL detected: " + rtmpsUrl);
			trace("RemoteConnection: Server must be configured to accept RTMPS on port 8443");
			trace("RemoteConnection: Red5 server must have RTMPS connector enabled");
			trace("RemoteConnection: SSL certificates must be properly configured");
		}
	}
	
}