package
{
	import com.kavalok.Global;
	import com.kavalok.StartupInfo;
	import com.kavalok.URLHelper;
	import com.kavalok.char.CharManager;
	import com.kavalok.collections.ArrayList;
	import com.kavalok.dto.CompetitionResultTO;
	import com.kavalok.dto.MoneyReportTO;
	import com.kavalok.dto.ServerPropertiesTO;
	import com.kavalok.dto.StateInfoTO;
	import com.kavalok.dto.friend.FriendTO;
	import com.kavalok.dto.home.CharHomeTO;
	import com.kavalok.dto.login.LoginResultTO;
	import com.kavalok.dto.login.MarketingInfoTO;
	import com.kavalok.dto.login.PartnerLoginCredentialsTO;
	import com.kavalok.dto.membership.SKUTO;
	import com.kavalok.dto.pet.PetTO;
	import com.kavalok.dto.robot.RobotItemSaveTO;
	import com.kavalok.dto.robot.RobotItemTO;
	import com.kavalok.dto.robot.RobotSaveTO;
	import com.kavalok.dto.robot.RobotScoreTO;
	import com.kavalok.dto.robot.RobotTO;
	import com.kavalok.dto.robot.RobotTeamScoreTO;
	import com.kavalok.dto.stuff.StuffItemLightTO;
	import com.kavalok.dto.stuff.StuffItemTO;
	import com.kavalok.dto.stuff.StuffTypeTO;
	import com.kavalok.events.EventSender;
	import com.kavalok.flash.geom.Point;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.chat.KeyboardListener;
	import com.kavalok.gameplay.chat.PrivateChatListener;
	import com.kavalok.gameplay.notifications.Notification;
	import com.kavalok.loaders.SafeLoader;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.quest.LocationQuestBase;
	import com.kavalok.quest.LocationQuestModuleBase;
	import com.kavalok.remoting.BaseDelegate;
	import com.kavalok.remoting.RemoteConnection;
	import com.kavalok.robots.Robots;
	import com.kavalok.utils.Debug;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.URLUtil;

	import flash.display.Sprite;
	import flash.system.Security;

	public class Kavalok
	{
			private var _connecting:McConnecting=new McConnecting();
	private var _readyEvent:EventSender=new EventSender();
	private var _assetsLoaded:Boolean = false;
	private var _connectionEstablished:Boolean = false;

			public function Kavalok(startupInfo:StartupInfo, root:Sprite)
	{
		var swfURL:String = root.loaderInfo.url.split('?')[0];
		Global.urlPrefix = swfURL.substr(0, swfURL.lastIndexOf('/') + 1);
		GraphUtils.stage = root.stage;
		Global.startupInfo=startupInfo;
		Global.initialize(root);
		Global.kavalokInstance = this;

			Security.allowDomain('*');

			trace(startupInfo);
			Debug.traceObject(startupInfo);

			SafeLoader.rootUrl = Global.urlPrefix;
			Localiztion.urlFormat = Global.urlPrefix + KavalokConstants.LOCALIZATION_URL_FORMAT;

			initRemoteObjects();
			initLocalization();
			BaseDelegate.defaultFaultHandler=onServiceFault;
			new PrivateChatListener().initialize();
			new KeyboardListener(root.stage);

					_connecting=new McConnecting();
		root.addChild(_connecting);
		
		Global.isLocked = true;
		
		loadAssets();
		
		// Start connection process immediately
		if (!Global.startupInfo.widget)
			Global.loginManager.login(Global.startupInfo);
		
		// Listen for connection success
		RemoteConnection.instance.connectEvent.addListener(onConnectionEstablished);
		// Listen for disconnection to reset connection state
		RemoteConnection.instance.disconnectEvent.addListener(onConnectionLost);
		}

		private function initRemoteObjects():void
		{
			LocationQuestBase;
			LocationQuestModuleBase;
			LoginResultTO.initialize();
			MoneyReportTO.initialize();
			PartnerLoginCredentialsTO.initialize();
			StateInfoTO.initialize();
			StuffTypeTO.initialize();
			StuffItemTO.initialize();
			StuffItemLightTO.initialize();
			Notification.initialize();
			Point.initialize();
			ArrayList.initialize();
			CharHomeTO.initialize();
			MarketingInfoTO.initialize();
			PetTO.initialize();
			FriendTO.initialize();
			CompetitionResultTO.initialize();
			ServerPropertiesTO.initialize();
			SKUTO.initialize();
			RobotTO.initialize();
			RobotItemTO.initialize();
			RobotSaveTO.initialize();
			RobotItemSaveTO.initialize();
			RobotScoreTO.initialize();
			RobotTeamScoreTO.initialize();
		}

		private function initLocalization():void
		{
			var locale:String = Global.startupInfo.locale;
			if (!locale)
				locale=Global.localSettings.locale;
			if (!locale || KavalokConstants.LOCALES.indexOf(locale) == -1)
				locale = KavalokConstants.LOCALES[0];

			Localiztion.locale=locale;
		}

		private function loadAssets():void
		{
			var urlList:Array =
			[
				URLHelper.charModels,
				URLHelper.petModels,
				URLHelper.charBodyURL(CharManager.DEFAULT_BODY)
			];

			for each (var robotName:String in Robots.names)
			{
				urlList.push(URLHelper.getRobotModelURL(robotName));
			}

			Global.classLibrary.callbackOnReady(onAssetsReady, urlList);
		}

			private function onAssetsReady():void
	{
		_assetsLoaded = true;
		checkReady();
	}
	
	private function onConnectionEstablished():void
	{
		_connectionEstablished = true;
		checkReady();
	}
	
	private function onConnectionLost():void
	{
		_connectionEstablished = false;
	}
	
	public function resetConnectionState():void
	{
		_connectionEstablished = false;
	}
	
	private function checkReady():void
	{
		if (_assetsLoaded && _connectionEstablished)
		{
			if (_connecting != null)
			{
				if (_connecting.parent != null)
				{
					GraphUtils.detachFromDisplay(_connecting);
				}
				_connecting.stop();
				_connecting = null;
			}

			Global.isLocked = false;

			_readyEvent.sendEvent();
		}
	}

		private function onServiceFault(fault:Object):void
		{
			if (Global.startupInfo.debugMode)
				traceServiceError(fault);
			if (Global.isLocked)
				Global.isLocked=false;
		}

		private function traceServiceError(info:Object):void
		{
			trace('Service error:');
			for(var prop:String in info)
			{
				trace(prop, info[prop]);
			}
		}

			public function get readyEvent():EventSender
	{
		return _readyEvent;
	}
	
	public function hideConnecting():void
	{
		if (_connecting != null)
		{
			if (_connecting.parent != null)
			{
				GraphUtils.detachFromDisplay(_connecting);
			}
			_connecting.stop();
			_connecting = null;
		}
	}

	}
}


