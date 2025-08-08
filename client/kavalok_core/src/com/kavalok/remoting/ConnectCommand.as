package com.kavalok.remoting
{
	import com.kavalok.events.EventSender;
	import com.kavalok.interfaces.ICommand;
    import com.kavalok.services.SystemService;
    import com.kavalok.utils.Timers;
	
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.events.NetStatusEvent;
    import flash.utils.Timer;

	public class ConnectCommand implements ICommand
	{
		
		private var _error : EventSender = new EventSender();
		private var _connectEvent : EventSender = new EventSender();
		private var _disconnectEvent : EventSender = new EventSender();
        private var _timeoutTimer:Timer;
        private var _timeoutMs:int = 2000;
        private var _attemptsMade:int = 0;
        private var _maxAttempts:int = 5;
		
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
            _attemptsMade = 0;
			RemoteConnection.instance.connectEvent.addListener(onConnect);
			RemoteConnection.instance.error.addListener(onError);
			tryConnect();
		}
		
		
		private function tryConnect() : void
		{
            _attemptsMade++;
			RemoteConnection.instance.connect();
            startTimeout();
		}
		
		private function onConnect() : void
		{
            clearTimeoutTimer();
			RemoteConnection.instance.connectEvent.removeListener(onConnect);
			RemoteConnection.instance.error.removeListener(onError);
			new SystemService().clientTick();
			connectEvent.sendEvent();
		}
		private function onError(event : Event) : void
		{
            clearTimeoutTimer();
            var code:String = (event is NetStatusEvent && NetStatusEvent(event).info && NetStatusEvent(event).info.code) ? NetStatusEvent(event).info.code : "Unknown";
            if (_attemptsMade < _maxAttempts) {
                // Wait the same 2 seconds as timeout to give server time to recover
                Timers.callAfter(retryConnect, _timeoutMs);
                return;
            }
            RemoteConnection.instance.connectEvent.removeListener(onConnect);
            RemoteConnection.instance.error.removeListener(onError);
            // Dispatch a NetStatusEvent with metadata so UI can show custom message
            errorEvent.sendEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code: code, attemptsMade: _attemptsMade, maxAttempts: _maxAttempts }));
		}
		
		private function onConnectTimeout():void
		{
            // If still not connected after timeout, open a new connection and retry
            clearTimeoutTimer();
            if (!RemoteConnection.instance.connected) {
                if (_attemptsMade < _maxAttempts) {
                    retryConnect();
                } else {
                    RemoteConnection.instance.connectEvent.removeListener(onConnect);
                    RemoteConnection.instance.error.removeListener(onError);
                    errorEvent.sendEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code: "ConnectTimeout", attemptsMade: _attemptsMade, maxAttempts: _maxAttempts }));
                }
            }
		}


        private function startTimeout():void {
            clearTimeoutTimer();
            _timeoutTimer = new Timer(_timeoutMs, 1);
            _timeoutTimer.addEventListener(TimerEvent.TIMER, onTimeoutTimer);
            _timeoutTimer.start();
        }

        private function onTimeoutTimer(e:TimerEvent):void {
            onConnectTimeout();
        }

        private function clearTimeoutTimer():void {
            if (_timeoutTimer != null) {
                try { _timeoutTimer.stop(); } catch (e:Error) {}
                _timeoutTimer.removeEventListener(TimerEvent.TIMER, onTimeoutTimer);
                _timeoutTimer = null;
            }
        }

        private function retryConnect():void {
            _attemptsMade++;
            RemoteConnection.instance.recreateNetConnection();
            RemoteConnection.instance.connect();
            startTimeout();
        }
	
	}
}