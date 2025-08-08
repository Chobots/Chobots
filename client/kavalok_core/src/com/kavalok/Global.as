package com.kavalok
{
	import com.kavalok.char.CharManager;
	import com.kavalok.constants.BrowserConstants;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.dto.ServerPropertiesTO;
	import com.kavalok.events.EventSender;
	import com.kavalok.external.ExternalCalls;
	import com.kavalok.gameplay.ClientTicker;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.LocalSettings;
	import com.kavalok.gameplay.MousePointer;
	import com.kavalok.gameplay.Music;
	import com.kavalok.gameplay.frame.GameFrameView;
	import com.kavalok.gameplay.notifications.Notifications;
	import com.kavalok.location.LocationManager;
	import com.kavalok.login.AuthenticationManager;
	import com.kavalok.login.LoginManager;
	import com.kavalok.messenger.MessageInbox;
	import com.kavalok.modules.ModuleManager;
	import com.kavalok.pets.PetManager;
	import com.kavalok.services.CharService;
	import com.kavalok.services.ErrorService;
	import com.kavalok.ui.WindowManager;
	import com.kavalok.utils.ClassLibrary;
	import com.kavalok.utils.KeyboardManager;
	import com.kavalok.utils.PerformanceManager;
	import com.kavalok.utils.Timers;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	
	public class Global
	{
		static public const MAIN_SITE_URL:String = 'http://www.chobots.com';
		static public var startupInfo:StartupInfo;
		static public var version:String;
		static public var chatSecurityKey:Array;
		static public var quests:Object = {};
		static public var youtubePlayer:DisplayObject; //added because of youtube player bugs
		static public var musicVolume:int;
		static public var soundVolume:int = 100;
		static public var showTips:Boolean;
		static public var showCharNames:Boolean;
		static public var acceptRequests:Boolean;
		static public var serverTimeDiff:int;
		static public var urlPrefix:String;
		static public var referer:String;
		static public var serverProperties:ServerPropertiesTO;
		static public var scale:Number = 1;
		static private var _lockRect:Sprite;
		static private var _clientTicker:ClientTicker = new ClientTicker();
		static public var partnerUserId:int = 0;
		static public var debugging:Boolean = false;
		static public var kavalokInstance:Kavalok;

		public static function handleError(error : Error):void
		{
			if (error.getStackTrace())
			{
				var message:String = Global.locationManager.locationId + '\n'
					+ error.message + '\n'
					+ error.getStackTrace();
					
				new ErrorService().addError(message);
			}

			throw error;
		}

		public static function initialize(root:Sprite):void
		{
			if (startupInfo.errorLogEnabled)
			{
				EventSender.errorHandler = handleError;
				Timers.errorHandler = handleError;
			}
			
			_lockRect = new Sprite();
			_lockRect.graphics.beginFill(0, 0);
			_lockRect.graphics.drawRect(0, 0, KavalokConstants.SCREEN_WIDTH, KavalokConstants.SCREEN_HEIGHT);
			_lockRect.graphics.endFill();
			_lockRect.cacheAsBitmap = true;
			
			_root = root;
			_root.addChild(_locationContainer);
			_root.addChild(_borderContainer);
			_root.addChild(_windowsContainer);
			_root.addChild(_dialogsContainer);
			_root.addChild(_topContainer);
			_root.scrollRect = KavalokConstants.SCREEN_RECT;
			
			_windowManager = new WindowManager();
			
			_stage = _root.stage;
			_keyboard = new KeyboardManager(_root);
			_performanceManager = new PerformanceManager();
			_performanceManager.quality = localSettings.quality;
			_inbox = new MessageInbox();
		}
		
		static public function getServerTime():Date
		{
			var result:Date = new Date();
			result.time = new Date().time - serverTimeDiff;
			return result;
		}
		
		public static function callExternal(functionName:String, parameter:String = null):void
		{
			if (ExternalInterface.available)
			{
				try
				{
					if (parameter)
						ExternalInterface.call(functionName, parameter);
					else
						ExternalInterface.call(functionName);
				}
				catch (e:Error)
				{
				}
			}
		}

		static public var superUser:Boolean = false;
		
		static private var _charsCache:Object = {};
		static public function get charsCache():Object
		{
			 return _charsCache;
		}
		
		static private var _tableGameCloseEvent:EventSender = new EventSender(String);
		static public function get tableGameCloseEvent():EventSender
		{
			 return _tableGameCloseEvent;
		}
		
		static private var _windowManager:WindowManager;
		static public function get windowManager():WindowManager
		{
			 return _windowManager;
		}
		
		private static var _resourceBundles : ResourceBundles = new ResourceBundles();
		public static function get resourceBundles():ResourceBundles
		{
			return _resourceBundles;
		}
		
		private static var _performanceManager:PerformanceManager;
		public static function get performanceManager():PerformanceManager
		{
			 return _performanceManager;
		}
		
		private static var _notifications : Notifications = new Notifications();
		public static function get notifications() : Notifications
		{
			return _notifications;
		}
		
		private static var _petManager:PetManager = new PetManager();
		public static function get petManager():PetManager
		{
			return _petManager;
		}

		private static var _stage:Stage;
		public static function get stage():Stage
		{
			return _stage;
		} 
		
		
		private static var _topContainer:Sprite = new Sprite();
		public static function get topContainer():Sprite
		{
			 return _topContainer;
		}
		
		private static var _borderContainer:Sprite = new Sprite();
		public static function get borderContainer():Sprite
		{
			 return _borderContainer;
		}
		
		private static var _windowsContainer:Sprite = new Sprite();
		public static function get windowsContainer():Sprite
		{
			return _windowsContainer;
		}
		
		private static var _dialogsContainer:Sprite = new Sprite();
		public static function get dialogsContainer():Sprite
		{
			 return _dialogsContainer;
		}
		
		private static var _locationContainer:Sprite = new Sprite();
		public static function get locationContainer():Sprite
		{
			 return _locationContainer;
		}
		
		private static var _root:Sprite;
		public static function get root():Sprite
		{
			return _root;
		}
		
		private static var _inbox:MessageInbox;
		public static function get inbox():MessageInbox
		{
			 return _inbox;
		}
		
		private static var _keyboard:KeyboardManager;
		public static function get keyboard():KeyboardManager
		{
			return _keyboard;
		} 
		
		private static var _localSettings:LocalSettings = new LocalSettings();
		public static function get localSettings():LocalSettings
		{
			 return _localSettings;
		}
		
		private static var _authManager:AuthenticationManager = new AuthenticationManager();
		public static function get authManager():AuthenticationManager
		{
			 return _authManager;
		}
		
		private static var _music:Music = new Music();
		public static function get music():Music
		{
			 return _music;
		}
		
		private static var _locationManager = new LocationManager();
		public static function get locationManager():LocationManager
		{
			return _locationManager;
		}

		private static var _frame:GameFrameView = new GameFrameView();
		public static function get frame():GameFrameView
		{
			return _frame;
		}
		
		private static var _classLibrary:ClassLibrary = new ClassLibrary();
		public static function get classLibrary():ClassLibrary
		{
			return _classLibrary;
		}
		
		private static var _moduleManager:ModuleManager = new ModuleManager();
		public static function get moduleManager():ModuleManager
		{
			return _moduleManager;
		}
		private static var _externalCalls:ExternalCalls = new ExternalCalls();
		public static function get externalCalls():ExternalCalls
		{
			return _externalCalls;
		}
		
		private static var _charManager:CharManager = new CharManager();
		public static function get charManager():CharManager
		{
			return _charManager;
		}
		

		private static var _loginManager = new LoginManager();
		public static function get loginManager():LoginManager
		{
			return _loginManager;
		}

		private static var _isLocked:Boolean = false;
		public static function get isLocked():Boolean
		{
			return _isLocked;
		}
		
		public static function get messages():Object
		{
			return resourceBundles.kavalok.messages;
		}
		
		public static function set isLocked(value:Boolean):void
		{
			if (_isLocked != value)
			{
				_isLocked = value;
				if (_isLocked)
				{
					if(Global.debugging && !_root)
						return;
					_root.addChild(_lockRect);
					MousePointer.setIconClass(MousePointer.BUSY);
				}
				else
				{
					if(Global.debugging && !_root)
						return;
					_root.removeChild(_lockRect);
					MousePointer.resetIcon();
				}
				_locationContainer.mouseChildren = !_isLocked;
				_topContainer.mouseChildren = !_isLocked;
				_borderContainer.mouseChildren = !_isLocked;
				_windowsContainer.mouseChildren = !_isLocked;
				_topContainer..mouseChildren = !_isLocked;
			}
			
			stage.focus = null;
		}
		
		public static function playSound(soundClass:Class, volume:Number = 1):void
		{
			var sound:Sound = new soundClass();
			var sndVol:Number = Global.soundVolume / 100 * volume;
			sound.play(0, 1, new SoundTransform(sndVol));
		}
		
		static public function saveSettings():void
		{
			new CharService().saveSettings(musicVolume, soundVolume, acceptRequests, showTips, showCharNames);
		}
		
		static public function openHomePage(e:Event = null):void
		{
			var request : URLRequest = new URLRequest("http://chobots.com");
			request.method = URLRequestMethod.GET;
			navigateToURL(request, BrowserConstants.BLANK);	
		}
	}
}