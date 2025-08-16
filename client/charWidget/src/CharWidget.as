package {
	import com.kavalok.Global;
	import com.kavalok.StartupInfo;
	import com.kavalok.char.Char;
	import com.kavalok.commands.char.GetCharCommand;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.windows.CharWindowView;
	import com.kavalok.remoting.BaseRed5Delegate;
	import com.kavalok.remoting.RemoteConnection;
	import com.kavalok.services.CharService;
	import com.kavalok.login.LoginManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width='235', height='308', backgroundColor='0xFFFFFF', framerate='24')]
	public class CharWidget extends Sprite
	{
		private var _window:CharWindowView;
		private var _char:Char;
		private var _readyCalled:Boolean = false;
		
		public function CharWidget()
		{
			super();
			if (stage)
				initialize();
			else
				addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			var info:StartupInfo = new StartupInfo();
			info.url = LoginManager.buildRtmpUrl();
			info.locale = loaderInfo.parameters.locale || "enUS";
			info.widget = KavalokConstants.WIDGET_CHAR;
			
			var kavalok:Kavalok = new Kavalok(info, this);
			kavalok.readyEvent.addListener(onReady);
		}
		
		private function onReady():void
		{
			if (_readyCalled)
			{
				return;
			}
			_readyCalled = true;
			
			// For widgets, we need to establish a connection before making service calls
			BaseRed5Delegate.defaultConnectionUrl = LoginManager.buildRtmpUrl();
			RemoteConnection.instance.connectEvent.addListener(onConnectionEstablished);
			RemoteConnection.instance.error.addListener(onConnectionError);
			RemoteConnection.instance.connect();
		}
		
		private function onConnectionEstablished():void
		{
			RemoteConnection.instance.connectEvent.removeListener(onConnectionEstablished);
			RemoteConnection.instance.error.removeListener(onConnectionError);
			// Now we can proceed with loading the character data
			onTimer();
		}
		
		private function onConnectionError(error:Object):void
		{
			RemoteConnection.instance.connectEvent.removeListener(onConnectionEstablished);
			RemoteConnection.instance.error.removeListener(onConnectionError);
			// Try to proceed anyway, but log the error
			onTimer();
		}
		
		private function onTimer():void
		{
			var login:String = loaderInfo.parameters.login;
			if (!login)
				login="go!";
			new GetCharCommand(login, 0, onViewComplete).execute();
		}
		
		private function onViewComplete(sender:GetCharCommand):void
		{
			_char = sender.char;
			if (_char && _char.id)
			{
				if (!_window)
				{
					_window = new CharWindowView(_char.id);
					_window.char = _char;
					addChild(_window.content);
				}
				else
				{
					_window.char = _char;
				}
				_window.refresh();
				getOnlineInfo();
			}
		}
		
		public function getOnlineInfo():void
		{
			if (_char.server)
			{
				_window.onlineInfo = Global.messages.onlineNow;
				RemoteConnection.instance.disconnect();
			}
			else
			{
				new CharService(onGetLastOnlineDay).getLastOnlineDay(_char.userId);
			}
		}
		
		private function onGetLastOnlineDay(result:int):void
		{
			var text:String = Global.messages.onlineDate + ' ';
			
			if (result == 0)
				text += Global.messages.today;
			else if (result == 1)
				text += Global.messages.yesterday;
			else
				text += String(result) + ' ' + Global.messages.daysAgo; 
			
			_window.onlineInfo = text;
			RemoteConnection.instance.disconnect();
		}
		
	}
}
