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
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.system.ApplicationDomain;
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
			if (!_connected) {
				trace("RemoteConnection: Connection still not established, sending error event");
				error.sendEvent(new Event("ConnectionTimeout"));
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
	
}