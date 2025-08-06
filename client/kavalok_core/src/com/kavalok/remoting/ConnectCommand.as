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
			createConnectionQueue();
			RemoteConnection.instance.connectEvent.addListener(onConnect);
			RemoteConnection.instance.error.addListener(onError);
			tryConnect();
		}
		
		
		private function tryConnect() : void
		{
			BaseRed5Delegate.defaultConnectionUrl = _connectionQueue.shift(); 
			RemoteConnection.instance.connect();
		}
		
		private function onConnect() : void
		{
			RemoteConnection.instance.connectEvent.removeListener(onConnect);
			RemoteConnection.instance.error.removeListener(onError);
			new SystemService().clientTick();
			connectEvent.sendEvent();
		}
		private function onError(event : Event) : void
		{
			if(_connectionQueue.length > 0)
			{
				Timers.callAfter(tryConnect); //dont't invoke normally cause exception will be thrown
			}
			else
			{
				RemoteConnection.instance.connectEvent.removeListener(onConnect);
				RemoteConnection.instance.error.removeListener(onError);
				errorEvent.sendEvent(event);
			}
		}
		private function createConnectionQueue() : void
		{
			_connectionQueue = [BaseRed5Delegate.defaultConnectionUrl];
		}
	
	}
}