package com.kavalok.login
{
	import com.kavalok.Global;
	import com.kavalok.StartupInfo;
	import com.kavalok.char.CharManager;
	import com.kavalok.constants.BrowserConstants;
	import com.kavalok.constants.Modules;
	import com.kavalok.dialogs.Dialogs;
	import com.kavalok.dto.ServerPropertiesTO;
	import com.kavalok.dto.login.LoginResultTO;
	import com.kavalok.dto.login.PartnerLoginCredentialsTO;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.messenger.commands.MessageBase;
	import com.kavalok.modules.ModuleBase;
	import com.kavalok.modules.ModuleEvents;
	import com.kavalok.remoting.BaseRed5Delegate;
	import com.kavalok.remoting.ConnectCommand;
	import com.kavalok.remoting.RemoteConnection;
	import com.kavalok.services.LoginService;
	import com.kavalok.services.ServerService;
	import com.kavalok.utils.Arrays;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.IdleManager;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.Timers;

	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;

	public class LoginManager
	{

		private var _info:StartupInfo;
		private var _autoLogin:Boolean;
		private var _server:String;
		private var _partnerUid:String;
		private var _connectCommand:ConnectCommand=new ConnectCommand();
		private var _logedIn:Boolean=false;
		private var _firstEnter:Boolean = true;
		private var _serverSelected:Boolean = false;

		private static var _idleManager:IdleManager;

		public function LoginManager()
		{
			_connectCommand.errorEvent.addListener(onConnectFault);
			RemoteConnection.instance.forceDisconnectEvent.addListener(onDisconnect);
		}

		public function get logedIn():Boolean
		{
			return _logedIn;
		}

		public function get userLogin():String
		{
			return _info.login;
		}

		public function get server():String
		{
			return _server;
		}

		private static function buildRtmpUrlInternal(serverPath:String = "kavalok"):String
		{
			// Build-time configuration - these will be replaced during Docker build
			const RTMP_USE_TLS:Boolean = ${RTMP_USE_TLS};
			const RTMP_HOSTNAME:String = "${RTMP_HOSTNAME}";
			const RTMP_PORT:String = "${RTMP_PORT}";
			
			if (RTMP_USE_TLS) {
				return "rtmps://" + RTMP_HOSTNAME + ":" + RTMP_PORT + "/" + serverPath;
			} else {
				return "rtmp://" + RTMP_HOSTNAME + ":" + RTMP_PORT + "/" + serverPath;
			}
		}

		public static function buildRtmpUrl():String
		{
			return buildRtmpUrlInternal("kavalok");
		}

		// Public static method to build RTMP URL with custom path
		public static function buildRtmpUrlFromPath(serverPath:String):String
		{
			return buildRtmpUrlInternal(serverPath);
		}

		public function login(startupInfo:StartupInfo):void
		{
			_autoLogin = Boolean(startupInfo.login);
			_server = startupInfo.server;
			_info = startupInfo;
			
			trace("LoginManager: login() called with server: " + _server);
			trace("LoginManager: _serverSelected: " + _serverSelected);
			trace("LoginManager: _info.url: " + _info.url);
			
			// Only use buildRtmpUrl if no specific server URL has been set
			if (!_serverSelected || !_info.url || _info.url == LoginManager.buildRtmpUrl()) {
				var targetUrl:String = LoginManager.buildRtmpUrl();
				BaseRed5Delegate.defaultConnectionUrl = targetUrl;
				_info.url = targetUrl;
				trace("LoginManager: Using default URL: " + targetUrl);
			} else {
				// Use the server-specific URL that was already set
				BaseRed5Delegate.defaultConnectionUrl = _info.url;
				trace("LoginManager: Using server-specific URL: " + _info.url);
			}

			trace("LoginManager: Final BaseRed5Delegate.defaultConnectionUrl: " + BaseRed5Delegate.defaultConnectionUrl);

			var isConnected:Boolean = RemoteConnection.instance.connected;
			var currentUri:String = isConnected ? RemoteConnection.instance.netConnection.uri : null;
			var targetUri:String = BaseRed5Delegate.defaultConnectionUrl;

			if (isConnected && currentUri == targetUri)
			{
				// Already connected to the desired server; proceed without reconnecting
				onConnectSuccess();
			}
			else
			{
				_connectCommand.connectEvent.addListener(onConnectSuccess);
				_connectCommand.execute();
			}
		}


		public function chooseServerAuto():void
		{
			new LoginService(onGetMostLoadedServer).getMostLoadedServer(_info.prefix?_info.moduleId:"loc3");
		}

		public function chooseServerManual():void
		{
			var events:ModuleEvents=Global.moduleManager.loadModule(Modules.SERVER_SELECT, {info:_info});
			events.destroyEvent.addListener(onServerSelect);
		}

		public function onGetMostLoadedServer(servername : String):void
		{
			if(servername){
				changeServer(servername, _info.prefix?_info.moduleId:"loc3");
			}else{
				var events:ModuleEvents=Global.moduleManager.loadModule(Modules.SERVER_SELECT, {info:_info});
				events.destroyEvent.addListener(onServerSelect);
			}
		}

		public function changeServer(server:String, location:String, parameters:Object=null):void
		{
			Global.isLocked=true;
//			if(_server == server)
//				return;
			_server=server;
			_info.moduleId=location;
			_info.moduleParams=parameters;
			_info.server=server;
			
			// Reset connection state in Kavalok instance to prevent null reference errors
			if (Global.kavalokInstance)
			{
				Global.kavalokInstance.resetConnectionState();
			}
			
			new ServerService(onGetServer).getServerAddress(server);

		}

		private function onGetServer(serverUrl:String):void
		{
			// ServerService.getServerAddress now returns the full RTMP/RTMPS URL
			var isConnected:Boolean = RemoteConnection.instance.connected;
			var currentUri:String = isConnected ? RemoteConnection.instance.netConnection.uri : null;
			
			trace("LoginManager: Server returned URL: " + serverUrl);
			trace("LoginManager: Current connection URI: " + currentUri);
			
			// Update target URL with the complete URL from server
			BaseRed5Delegate.defaultConnectionUrl = serverUrl;
			_info.url = serverUrl;
			_serverSelected = true;

			trace("LoginManager: Set BaseRed5Delegate.defaultConnectionUrl to: " + BaseRed5Delegate.defaultConnectionUrl);
			trace("LoginManager: Set _info.url to: " + _info.url);
			trace("LoginManager: _serverSelected is now: " + _serverSelected);

			// Only disconnect if switching to a different server
			if (isConnected && currentUri != serverUrl)
			{
				RemoteConnection.instance.disconnect();
			}

			login(_info);
		}

		private function onConnectSuccess():void
		{
			// Safely remove listener only if present, since we may call this directly when already connected
			_connectCommand.connectEvent.removeListenerIfHas(onConnectSuccess);
			new LoginService(onGetServerProperties).getServerProperties();
		}
		
		private function onGetServerProperties(result:ServerPropertiesTO):void
		{
			Global.serverProperties = result;
			doLogin();
		}
		
		private function doLogin():void
		{
			Global.isLocked=false;
			_partnerUid=Global.startupInfo.partnerUid;

			if (_info.prefix && !_info.login) {
				// Only use freeLoginByPrefix for true guests
				var service:LoginService=new LoginService(onLoginSuccess, onLoginFault);
				service.freeLoginByPrefix(_info.prefix);
			} else if (_info.login) {
				if (Global.startupInfo.loginToken) {
					Global.authManager.loginEvent.addListenerIfHasNot(onAuthLoginSuccess);
					Global.authManager.faultEvent.addListenerIfHasNot(onAuthLoginFault);
					Global.authManager.tryLoginWithToken(_info.login, Global.startupInfo.loginToken);
				}
			} else if (_partnerUid) {
				new LoginService(onGetPartnerCredentials, onLoginFault).getPartnerLoginInfo(_partnerUid);
			} else if (_info.moduleId) {
				if (Global.moduleManager.loading)
					Global.moduleManager.abortLoading();
				Global.moduleManager.loadModule(_info.moduleId, {info:_info});
			} else {
				if (Global.moduleManager.loading)
					Global.moduleManager.abortLoading();
				var defaultEvents:ModuleEvents=Global.moduleManager.loadModule(Modules.LOGIN, {info:_info});
				defaultEvents.destroyEvent.addListener(onGuiLogin);
			}
		}

		private function onServerSelect(module:ModuleBase):void
		{
			changeServer(_info.server, _info.moduleId);
		}



		private function onGuiLogin(module:ModuleBase):void
		{
			_logedIn = true;
			if(Global.charManager.age<=10)
				chooseServerAuto();
			else
				chooseServerManual();
		}

		private function onGetPartnerCredentials(result:PartnerLoginCredentialsTO):void
		{
			if (!result.needRegistartion)
			{
				_info.login=result.login;
				Global.partnerUserId = result.userId;
				chooseServerAuto();
			}
			else
			{
				var moduleParameters:Object = {
					info: _info,
					mode : LoginModes.REGISTER_FROM_PARTNER,
					partnerUid: _partnerUid
				}
				var events:ModuleEvents	= Global.moduleManager.loadModule(
					Modules.LOGIN, moduleParameters);
				events.destroyEvent.addListener(onGuiLogin);
			}
		}

		private function onLoginSuccess(result:String):void
		{
			handleLoginSuccess(result, null);
		}

		private function onLoginFault(result:Object):void
		{
			handleLoginFault();
		}
		
		private function onAuthLoginSuccess(result:LoginResultTO):void
		{
			Global.authManager.loginEvent.removeListenerIfHas(onAuthLoginSuccess);
			Global.authManager.faultEvent.removeListenerIfHas(onAuthLoginFault);
			handleLoginSuccess(null, result);
		}
		
		private function onAuthLoginFault(result:LoginResultTO):void
		{
			Global.authManager.loginEvent.removeListenerIfHas(onAuthLoginSuccess);
			Global.authManager.faultEvent.removeListenerIfHas(onAuthLoginFault);
			
			// Clear the invalid token
			Global.startupInfo.loginToken = null;
			
			handleLoginFault();
		}
		
		private function handleLoginSuccess(guestResult:String, authResult:LoginResultTO):void
		{
			_logedIn=true;
			
			if (guestResult && _info.prefix) {
				_info.login = guestResult;
			}
			
			if (authResult && authResult.loginToken) {
				// Store the new login token for future use
				Global.startupInfo.loginToken = authResult.loginToken;
			}

			initChar();
			
			if (_firstEnter)
			{
				_firstEnter = false;
				checkPlayerVersion();
			}
		}
		
		private function handleLoginFault():void
		{
			Dialogs.showOkDialog("Login fault :" + _info.login + ". Try to clear out your browser cache. If it's doesn't work, contact support.");
		}

		private function initChar():void
		{
			Global.isLocked=true;
			Global.charManager.readyEvent.addListener(onCharReady);
			Global.charManager.initialize();
		}

		private function onCharReady():void
		{
			if (_idleManager == null)
			{
				_idleManager=new IdleManager();
				_idleManager.start();
			}
			Global.charManager.readyEvent.removeListener(onCharReady);
			Global.isLocked=false;
			Global.frame.initialize();
			Global.charManager.stuffs.processStuffCommands();
			Global.borderContainer.addChild(Global.frame.content);
			createLocation();
		}

		public function createLocation():void
		{
			var moduleId:String;
			var params:Object;

			if (_info.moduleId)
			{
				moduleId=_info.moduleId;
				params=_info.moduleParams;
			}
			else if (Global.charManager.firstLogin)
			{
				moduleId=Arrays.randomItem(KavalokConstants.STARTUP_LOCS);
			}
			else
			{
				moduleId=Modules.MAP;
				params={closeDisabled:true};
			}

			Global.moduleManager.loadModule(moduleId, params);
		}
		
		private function checkPlayerVersion():void
		{
			var version:String = Capabilities.version;
			var str1:String = version.split(' ')[1];
			var majorNum:String = str1.split(',')[0];
			
			if (majorNum == '9')
			{
				var text:String = Strings.substitute(Global.messages.updateFlashPlayer,
					'<u><a target="_blank" href="http://get.adobe.com/flashplayer/">http://get.adobe.com/flashplayer/</a></u>');
				var message:MessageBase = new MessageBase();
				message.sender = Global.messages.chobotsTeam;
				message.text = text;
				Global.inbox.addMessage(message);
			}
		}

		private function onConnectFault(event:NetStatusEvent):void
		{
			showError(event.info);
		}

		private function onDisconnect():void
		{
			showError();
		}

		private static function traceServiceError(info:Object):void
		{
			trace('Service error:');
			for(var prop:String in info)
			{
				trace(prop, info[prop]);
			}
		}

	private static function parseDataFromStackTrace(stackTrace:String):Object {
	    //extract function name from the stack trace
	    var parsedDataObj:Object = {fileName:"",packageName:"",className:"",functionName:""};
	    var nameResults:Array;
	    //extract the package from the class name
	    var matchExpression:RegExp;
	    var isFileNameFound:Boolean;
	    //if running in debugger you are going to remove that data
	    var removeDebuggerData:RegExp;
	    removeDebuggerData = /\[.*?\]/msgi;
	    stackTrace = stackTrace.replace(removeDebuggerData,"");
	    //remove the Error message at the top of the stack trace
	    var removeTop:RegExp;
	    removeTop = /^Error.*?at\s/msi;
	    stackTrace = stackTrace.replace(removeTop,"");
	    stackTrace = "at "+stackTrace;
	    //get file name
	    matchExpression = /(at\s)*(.*?)_fla::/i;
	    nameResults = stackTrace.match(matchExpression);
	    if (nameResults != null && nameResults.length > 2) {
	        parsedDataObj.fileName = nameResults[2];
	        parsedDataObj.fileName =  parsedDataObj.fileName.replace(/^\s*at\s/i,"")+".fla";
	        isFileNameFound = true;
	    }
	    //match timeline data
	    matchExpression = /^at\s(.*?)::(.*?)\/(.*?)::(.*?)\(\)/i;
	    nameResults = stackTrace.match(matchExpression);
	
	    if (nameResults != null && nameResults.length > 4) {
	        if (!isFileNameFound) {
	            parsedDataObj.fileName = String(nameResults[1]).replace(/_fla$/i,".fla");
	            parsedDataObj.fileName = parsedDataObj.fileName.replace(/^at\s/i,"");
	        }
	        parsedDataObj.packageName = String(nameResults[1]);
	        parsedDataObj.className = String(nameResults[2]);
	        parsedDataObj.functionName = String(nameResults[4]);
	    } else {
	        //match function in a class of format com.package::SomeClass/somefunction()
	        matchExpression = /^at\s(.*?)::(.*?)\/(.*?)\(\)/i;
	        nameResults = stackTrace.match(matchExpression);
	        if (nameResults != null && nameResults.length > 3) {
	            if (!isFileNameFound) {
	                parsedDataObj.fileName = String(nameResults[2])+".as";
	            }
	            parsedDataObj.packageName = nameResults[1];
	            parsedDataObj.className = String(nameResults[2]);
	            parsedDataObj.functionName = String(nameResults[3]);
	        } else {
	            //match a contructor with $iinit
	            matchExpression = /^at\s(.*?)::(.*?)\$(.*?)\(\)/i;
	            nameResults = stackTrace.match(matchExpression);
	            if (nameResults != null && nameResults.length > 3) {
	                if (!isFileNameFound) {
	                    parsedDataObj.fileName = String(nameResults[2])+".as";
	                }
	                parsedDataObj.packageName = String(nameResults[1]);
	                parsedDataObj.className = String(nameResults[2]);
	                parsedDataObj.functionName = String(nameResults[2]);
	            } else {
	                //match a contructor that looks like this com.package::SomeClassConstructor()
	                matchExpression = /^at\s(.*?)::(.*?)\(\)/i;
	                nameResults = stackTrace.match(matchExpression);
	                if (nameResults != null && nameResults.length > 2) {
	                    if (!isFileNameFound) {
	                        parsedDataObj.fileName = String(nameResults[2])+".as";
	                    }
	                parsedDataObj.packageName = String(nameResults[1]);
	                parsedDataObj.className = String(nameResults[2]);
	                parsedDataObj.functionName = String(nameResults[2]);
	                } else {
	                    //can't find a match - this is a catch all, you never know, 
	                    //if you find situations where this does not work please , 
	                    //post the solution in the comments.
	                    if (!isFileNameFound) {
	                        parsedDataObj.fileName = "NO_DATA";
	                    }
	                    parsedDataObj.packageName = "NO_DATA";
	                    parsedDataObj.className = "NO_DATA";
	                    parsedDataObj.functionName = "NO_DATA";
	                }
	            }
	        }
	    }
	    return parsedDataObj;
	}
        public static function showError(info:Object=null):void
		{
			try {
				Global.isLocked = false;
			} catch (e:Error) {
				// Ignore
			}

            var locMess:String = Global.resourceBundles.kavalok.messages.connectionErrorRedirect;
            var defaultMessage:String = locMess ? locMess : "Connection error. Please refresh.";
            var message:String = defaultMessage;
            trace("Connection error info: "+info);
            traceServiceError(info);

			var code:String = (info && info.hasOwnProperty("code")) ? String(info.code) : "";
			if (code == "ConnectTimeout" || code == "NetConnection.Connect.Failed") {
				message = "Connection Error.\nA connection could not be made to Chobots.";
			} else {
				message = defaultMessage;
			}

			// Hide McConnecting if it's still showing
			if (Global.kavalokInstance) {
				Global.kavalokInstance.hideConnecting();
			}

			//first thing that needs to be done is an error needs to be thrown,
			//this will give you a stack trace for the place where the error was thrown.
			var parsedData:Object;
			var stackTrace:String;
			//here is where the error is artificialy  thrown,
			try {
				throw new Error("");
			} catch (e:Error) {
				stackTrace = e.getStackTrace();
			}
			parsedData = parseDataFromStackTrace(stackTrace);
			trace("stackTrace: "+stackTrace);
			trace("fileName : "+parsedData.fileName);
			trace("packageName : "+parsedData.packageName);
			trace("className : "+parsedData.className);
			trace("functionName : "+parsedData.functionName);



            Dialogs.showOkDialog(message, false);
            // Disable redirect as game doesn't run in a browser context anymore
			// Timers.callAfter(doRedirect, 10000)
		}

		private static function doRedirect():void
		{
			var si : StartupInfo = Global.startupInfo;
			var redirectURL:String;
			if(si)
				redirectURL = si.redirectURL;
			else if(ExternalInterface.available)
				ExternalInterface.call("document.location.reload()");
			if (redirectURL)
				navigateToURL(new URLRequest(redirectURL), BrowserConstants.SELF);
		}
	}
}




