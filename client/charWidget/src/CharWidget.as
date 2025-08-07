package {
	import com.kavalok.Global;
	import com.kavalok.StartupInfo;
	import com.kavalok.char.Char;
	import com.kavalok.commands.char.GetCharCommand;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.windows.CharWindowView;
	import com.kavalok.remoting.BaseRed5Delegate;
	import com.kavalok.remoting.ConnectCommand;
	import com.kavalok.remoting.RemoteConnection;
	import com.kavalok.services.CharService;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.URLUtil;
	import com.kavalok.constants.ConnectionConfig;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	[SWF(width='235', height='308', backgroundColor='0xFFFFFF', framerate='24')]
	public class CharWidget extends Sprite
	{
		private var _updateTimer:Timer = new Timer(1000 * 60 * 2);
		private var _window:CharWindowView;
		private var _char:Char;
		
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
			
			var swfURL:String = loaderInfo.url.split('&')[0];
			var urlPrefix:String = swfURL.substr(0, swfURL.lastIndexOf('/') + 1);
			var mainURL:String = urlPrefix + 'Main.swf';
			var serverName:String = getServerNameFromURL(swfURL);
			
			var info:StartupInfo = new StartupInfo();
			info.url = ConnectionConfig.buildRtmpUrl();
			info.locale = loaderInfo.parameters.locale || "enUS";
			info.widget = KavalokConstants.WIDGET_CHAR;
			
			var kavalok:Kavalok = new Kavalok(info, this);
			kavalok.readyEvent.addListener(onReady);
		}
		
		private function getServerNameFromURL(url:String):String
		{
			var result:String = URLUtil.getServerName(url);
			result = result.substring(result.indexOf(".") + 1, result.length);
			
			return (result.length > 0) ? result : 'localhost'; 
		}
		
		private function onReady():void
		{
			BaseRed5Delegate.defaultConnectionUrl = ConnectionConfig.buildRtmpUrl();
			var command:ConnectCommand = new ConnectCommand();
			command.connectEvent.addListener(onConnect);
			command.execute();
		}
		
		private function onConnect():void
		{
			// turn off autoupdate
			//_updateTimer.addEventListener(TimerEvent.TIMER, onTimer);
			//_updateTimer.start();
			onTimer();
		}
		
		private function onTimer(e:TimerEvent = null):void
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
