package com.kavalok.remoting
{
	import com.kavalok.events.EventSender;
	import com.kavalok.interfaces.ICommand;
	import com.kavalok.services.SystemService;
	import com.kavalok.utils.Timers;
	
	import flash.events.Event;

	public class ConnectCommand implements ICommand
	{
		
		private var _error : EventSender = new EventSender();
		private var _connectEvent : EventSender = new EventSender();
		private var _disconnectEvent : EventSender = new EventSender();
		private var _connectionQueue : Array = [];
		
		public function ConnectCommand()
		{
		}

		public function get errorEvent() : EventSender
		{
			return _error;
		}
	
		public function get connectEvent() : EventSender
		{
			return _connectEvent;
		}

		public function execute():void
		{
			trace("ConnectCommand: execute() called");
			createConnectionQueue();
			trace("ConnectCommand: connection queue created with " + _connectionQueue.length + " URLs");
			RemoteConnection.instance.connectEvent.addListener(onConnect);
			RemoteConnection.instance.error.addListener(onError);
			trace("ConnectCommand: event listeners added");
			tryConnect();
		}
		
		
		private function tryConnect() : void
		{
			trace("ConnectCommand: tryConnect() called");
			var url:String = _connectionQueue.shift();
			trace("ConnectCommand: trying URL: " + url);
			BaseRed5Delegate.defaultConnectionUrl = url; 
			trace("ConnectCommand: BaseRed5Delegate.defaultConnectionUrl set to: " + BaseRed5Delegate.defaultConnectionUrl);
			RemoteConnection.instance.connect();
		}
		
		private function onConnect() : void
		{
			trace("ConnectCommand: onConnect() called - connection successful");
			RemoteConnection.instance.connectEvent.removeListener(onConnect);
			RemoteConnection.instance.error.removeListener(onError);
			trace("ConnectCommand: event listeners removed");
			new SystemService().clientTick();
			trace("ConnectCommand: SystemService.clientTick() called");
			connectEvent.sendEvent();
			trace("ConnectCommand: connect event sent");
		}
		private function onError(event : Event) : void
		{
			trace("ConnectCommand: onError() called");
			trace("ConnectCommand: error event: " + event);
			trace("ConnectCommand: remaining URLs in queue: " + _connectionQueue.length);
			
			if(_connectionQueue.length > 0)
			{
				trace("ConnectCommand: retrying with next URL in queue");
				Timers.callAfter(tryConnect); //dont't invoke normally cause exception will be thrown
			}
			else
			{
				trace("ConnectCommand: no more URLs in queue, connection failed");
				RemoteConnection.instance.connectEvent.removeListener(onConnect);
				RemoteConnection.instance.error.removeListener(onError);
				errorEvent.sendEvent(event);
				trace("ConnectCommand: error event sent");
			}
		}
		private function createConnectionQueue() : void
		{
			trace("ConnectCommand: createConnectionQueue() called");
			trace("ConnectCommand: BaseRed5Delegate.defaultConnectionUrl: " + BaseRed5Delegate.defaultConnectionUrl);
			_connectionQueue = [BaseRed5Delegate.defaultConnectionUrl];
			trace("ConnectCommand: connection queue created with URL: " + _connectionQueue[0]);
		}
	
	}
}