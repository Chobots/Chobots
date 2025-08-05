package com.kavalok.login
{
	import com.kavalok.Global;
	import com.kavalok.dto.login.LoginResultTO;
	import com.kavalok.events.EventSender;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.services.LoginService;
	
	import flash.net.LocalConnection;
	

	public class AuthenticationManager
	{
		public static const SUCCESS:String = "success";
		public static const NEED_REGISTRATION:String = "need_registration";
		public static const ERROR_UNKNOWN:String = "unknown";
		public static const ERROR_OUTDATED_SWF:String = "oudated_swf";
		public static const ERROR_LOGIN_EXISTS:String = "login_exists";
		public static const ERROR_LOGIN_BANNED:String = "login_banned";
		public static const ERROR_IP_BANNED:String = "ip_banned";
		public static const ERROR_LOGIN_NOT_ACTIVE:String = "login_not_active";
		public static const ERROR_EMAIL_EXISTS:String = "email_exists";
		public static const ERROR_BAD_LOGIN:String = "bad_login";
		public static const ERROR_BAD_PASSW:String = "bad_passw";
		public static const ERROR_LOGIN_DISABLED:String = "disabled";
		public static const ERROR_FAMILY_FULL:String = "familyIsFull";
		public static const ERROR_LOCAL_CONNECTION:String = "localConnectionExists";
		public static const REGISTRATION_DISABLED:String = "registration_disabled";
		
		private var _loginEvent : EventSender = new EventSender();
		private var _logoutEvent : EventSender = new EventSender();
		private var _faultEvent : EventSender = new EventSender();
		private var _localConnection:LocalConnection;
		
		public function tryLogin(login:String, passw:String) : void
		{
			if (checkLocalConnection())
			{
				new LoginService(onResult, onFault).login(login, passw, Localiztion.locale);
			}
			else
			{
				var result:LoginResultTO = new LoginResultTO();
				result.active = false;
				result.success = false;
				result.reason = ERROR_LOCAL_CONNECTION;
				_faultEvent.sendEvent(result);
			}
		}
		
		public function tryLoginWithToken(login:String, token:String) : void
		{
			if (checkLocalConnection())
			{
				new LoginService(onResult, onFault).loginWithToken(login, token, Localiztion.locale);
			}
			else
			{
				var result:LoginResultTO = new LoginResultTO();
				result.active = false;
				result.success = false;
				result.reason = ERROR_LOCAL_CONNECTION;
				_faultEvent.sendEvent(result);
			}
		}
		
		private function checkLocalConnection():Boolean
		{
			return true; //added temporarily. need research;
			if (Global.startupInfo.url.indexOf('kavalok.com') == 0)
				return true;
			
			var connectionName:String = 'www.chobots.com|' + Global.startupInfo.url;
			_localConnection = new LocalConnection();
			_localConnection.client = this;
			
			try
			{
				_localConnection.connect(connectionName);
			}
			catch (e:Error)
			{
				_localConnection = null;
				trace(e.message);
			}
			
			return Boolean(_localConnection);
		}

		private function onFault(fault : Object) : void
		{
			var result : LoginResultTO = new LoginResultTO();
			result.active = false;
			result.success = false;
			if(fault.application && fault.application=="java.lang.NoSuchMethodException")
				result.reason = ERROR_OUTDATED_SWF;
			else
				result.reason = ERROR_UNKNOWN;
			_faultEvent.sendEvent(result);
		}
		
		private function onResult(result:LoginResultTO) : void
		{
			if (result.success)
			{
				Global.charManager.age=result.age;
				_loginEvent.sendEvent(result);
			}
			else
			{
				if(_localConnection)
				{
					_localConnection.close();
					_localConnection = null;
				}
				_faultEvent.sendEvent(result);
			}
		}
		
		public function get loginEvent():EventSender { return _loginEvent; }
	
		public function get faultEvent():EventSender { return _faultEvent; }
	
		public function get logoutEvent():EventSender { return _logoutEvent; }
		
	}
}