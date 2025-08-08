package com.kavalok.kongregateLoader
{
	import com.kavalok.Global;
	import com.kavalok.StartupInfo;
	import com.kavalok.URLHelper;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.ToolTips;
	import com.kavalok.gameplay.commands.AddMoneyCommand;
	import com.kavalok.games.ReadyClient;
	import com.kavalok.kongregateLoader.utils.LoaderViewDecorator;
	import com.kavalok.loaders.ILoaderView;
	import com.kavalok.loaders.LocationLoaderView;
	import com.kavalok.loaders.SafeLoader;
	import com.kavalok.modules.LocationModule;
	import com.kavalok.utils.Strings;
	import com.kavalok.login.LoginManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import mx.core.Singleton;
	import mx.resources.ResourceManagerImpl;
	import mx.utils.URLUtil;

	public class KongregateGame extends Sprite
	{
		public var kongregateUser : Object;

		private var _loaderView : ILoaderView;
		private var _game : String;
		private var _location : String;
		private var _userName : String;
		private var _domain : String;
		private var _rtmpHost : String;
		
		public function KongregateGame(game : String, location : String, rtmpHost : String = "chobots.com")
		{
			super();
			Security.allowDomain("chat.kongregate.com");
			Security.allowDomain("kongregate.com");
			ReadyClient;LocationModule;AddMoneyCommand;ToolTips;
			Singleton.registerClass("mx.resources::IResourceManager", ResourceManagerImpl);
			_game = game;
			_location = location;
			_rtmpHost = rtmpHost;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event : Event) : void
		{
			_domain = URLUtil.getServerName(loaderInfo.url);
			if(_domain)
			{
				KavalokConstants.LOCALIZATION_URL_FORMAT = "http://" + _domain + "/game/resources/localization/{0}.{1}.xml";
				URLHelper.RESOURCES_PATH_FORMAT = "http://" + _domain + "/game/resources/{0}/{1}.swf";
				URLHelper.MUSIC_PATH_FORMAT = "http://" + _domain + "/game/resources/music/{0}.mp3";
			}

			_loaderView = new LocationLoaderView();
			addChild(_loaderView.content);
			var decorator : LoaderViewDecorator = new LoaderViewDecorator(_loaderView, 0, 50);
			var loader : SafeLoader = new SafeLoader(decorator);
			loader.completeEvent.addListener(onLocationLoaded);
			loader.load(new URLRequest(URLHelper.locationUrl(_location)));
		}
		private function onLocationLoaded() : void
		{
			var decorator : LoaderViewDecorator = new LoaderViewDecorator(_loaderView, 50, 100);
			var loader : SafeLoader = new SafeLoader(decorator);
			loader.completeEvent.addListener(onGameLoaded);
			loader.load(new URLRequest(URLHelper.moduleUrl(_game)));
		}
		
		private function onGameLoaded() : void
		{
			Global.frame.persistentUser = false;
			Global.showTips = false;
			removeChild(_loaderView.content);
			
			var info:StartupInfo = new StartupInfo();
			if(kongregateUser == null || kongregateUser.isGuest)
				info.prefix = "[k]guest_";
			else
				info.prefix = "[k]" + kongregateUser.name.toLowerCase() + "_";
				
			info.server = "Serv1";
			if(_domain)
				info.url = Strings.substitute(Kavalok.SHORT_LOGIN_URL_FORMAT, _domain);
			info.url = LoginManager.buildRtmpUrl();
			info.errorLogEnabled = false;
			info.moduleId = _location;
//			info.moduleId = _game;
			info.locale = "enUS"
//			SafeLoader.rootUrl = "http://www.kavalok.com/game/"
			var instance:Kavalok = new Kavalok(info);
			addChild(instance);
		}
		
	}
}