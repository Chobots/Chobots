package
{
	import com.kavalok.Global;
	import com.kavalok.constants.Modules;
	import com.kavalok.dto.ServerConfigTO;
	import com.kavalok.dto.WorldConfigTO;
	import com.kavalok.dto.login.ActivationTO;
	import com.kavalok.dto.login.LoginResultTO;
	import com.kavalok.dto.login.PartnerLoginCredentialsTO;
	import com.kavalok.external.ExternalCalls;
	import com.kavalok.gameplay.ViewStackPage;
	import com.kavalok.gameplay.controls.ViewStackSwitcher;
	import com.kavalok.gameplay.controls.effects.AlphaHideEffect;
	import com.kavalok.gameplay.controls.effects.AlphaShowEffect;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.login.AuthenticationManager;
	import com.kavalok.login.LoginModes;
	import com.kavalok.login.redesign.ActivationView;
	import com.kavalok.login.redesign.EntranceView;
	import com.kavalok.login.redesign.LoginView;
	import com.kavalok.login.redesign.RegisterWizardView;
	import com.kavalok.login.redesign.RestorePasswordView;
	import com.kavalok.login.redesign.SelectChatView;
	import com.kavalok.login.redesign.registration.data.RegistrationData;
	import com.kavalok.modules.LocationModule;
	import com.kavalok.services.AdminService;
	import com.kavalok.services.LoginService;
	import com.kavalok.utils.ResourceScanner;
	import com.kavalok.dto.ClientServerConfigTO;
	
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;

	public class Login extends LocationModule
	{

		private static var bundle:ResourceBundle=Localiztion.getBundle(Modules.LOGIN);

		private var _content:McMainContainer;
		private var _viewStack:ViewStackSwitcher;
		private var _entranceView:EntranceView;
		private var _activationView:ActivationView;
		private var _loginView:LoginView;
		private var _registerView:RegisterWizardView;
		private var _restorePasswordView:RestorePasswordView;
		private var _selectChatView:SelectChatView;
		private var _login:String;
		private var _pass:String;
		private var _partnerUid:String;
//		private var _info : StartupInfo;
		private var _tabChildren:Boolean;
		private var _config:ClientServerConfigTO;
		private var _skipActivation:Boolean;
		private var _mode:String;
		private var _previousLocId:String;
		private var _previousLocParams:Object;
		private var _lastView:ViewStackPage;
		private var _userEnteredPassword:String;

		public function Login()
		{
			ActivationTO.initialize();
			ServerConfigTO.initialize();
			WorldConfigTO.initialize();
			ClientServerConfigTO.initialize();
			_previousLocId = this.parameters.locId || Global.locationManager.locationId;
			var invitationParams : Object = Global.locationManager.location?Global.locationManager.location.invitationParams : null;
			_previousLocParams = this.parameters.params || invitationParams;
		}

		override public function initialize():void
		{
			Global.externalCalls.changeModeEvent.addListener(setMode);
			Global.authManager.faultEvent.addListenerIfHasNot(onLoginFault);
			_content=new McMainContainer();
			new ResourceScanner().apply(_content);
			addChild(_content);

			_content.errorMessage.visible=false;
			_content.successMessage.visible=false;

			_activationView=new ActivationView(_content.viewStack.activationView);
			_activationView.loginEvent.addListener(onActivationPlay);
			_activationView.registerEvent.addListener(onRegisterSelect);
			_activationView.messageEvent.addListener(showSuccess);

			_entranceView=new EntranceView(_content.viewStack.entranceView);
			_entranceView.loginEvent.addListener(onLoginSelect);
			_entranceView.registerEvent.addListener(onRegisterSelect);

			_restorePasswordView=new RestorePasswordView(_content.viewStack.restorePasswordView);
			_restorePasswordView.messageEvent.addListener(showSuccess);
			_restorePasswordView.errorEvent.addListener(showError);
			_restorePasswordView.backEvent.addListener(onLoginSelect);


			_loginView=new LoginView(_content.viewStack.loginView);
			_loginView.guestEnabled=false;
			_loginView.registerEvent.addListener(onRegisterSelect);
			_loginView.restorePasswordEvent.addListener(onRestorePassword);
			_loginView.errorEvent.addListener(showError);
			_loginView.loginEvent.addListener(onTryLogin);
			_loginView.messageEvent.addListener(showSuccess);

			_registerView=new RegisterWizardView(_content.viewStack.registerView);
			_registerView.errorEvent.addListener(showError);
			_registerView.finishEvent.addListener(onRegister);
			_registerView.backEvent.addListener(onRegisterBack);

			_selectChatView=new SelectChatView(_content.viewStack.activateAccountView);
			_selectChatView.errorEvent.addListener(showError);
			_selectChatView.messageEvent.addListener(showSuccess);
			_selectChatView.showLoginEvent.addListener(onLoginSelect);

			_viewStack=new ViewStackSwitcher();
			_viewStack.showEffect=new AlphaShowEffect();
			_viewStack.hideEffect=new AlphaHideEffect();
			_viewStack.addPage(_entranceView);
			_viewStack.addPage(_loginView);
			_viewStack.addPage(_restorePasswordView);
			_viewStack.addPage(_activationView);
			_viewStack.addPage(_registerView);
			_viewStack.addPage(_selectChatView);


			selectStartPage();

//			_info = parameters.info;
			_tabChildren=Global.stage.tabChildren;

			Global.stage.tabChildren=true;

			destroyEvent.addListener(onDestroy);

			new AdminService(onGetConfig).getClientConfig();
			readyEvent.sendEvent();
		}

		private function setMode():void
		{
			_mode=Global.externalCalls.getMode();

			if (_mode == ExternalCalls.LOGIN)
			{
				_viewStack.selectedPage=_loginView;
				_entranceView.content.visible=false;
			}
			else if (_mode == ExternalCalls.REGISTER)
			{
				_viewStack.selectedPage=_registerView;
				_entranceView.content.visible=false;
			}

		}

		private function selectStartPage():void
		{
			/*
			if (Global.border)
				Global.border.visible = Global.startupInfo.mppc_partner;
			if (loadVars)
			{
				_login=loadVars.login;
			}*/
			
			_mode = parameters.mode;
			if (ExternalInterface.available)
				_mode = _mode || Global.externalCalls.getMode();

			_entranceView.content.visible=false;
			if (parameters.showActivation == "true")
			{
				_activationView.login=parameters.login;
				_viewStack.selectedPage=_activationView;
			}
			else if (_mode == LoginModes.REGISTER_FROM_FAMILY)
			{
				_viewStack.selectedPage=_registerView;
				_registerView.familyEmail=parameters.familyEmail;
			}
			else if (_mode == ExternalCalls.LOGIN)
			{
				_viewStack.selectedPage=_loginView;
			}
			else if (_mode == ExternalCalls.REGISTER)
			{
				_viewStack.selectedPage=_registerView;
			}
			else if (_mode == ExternalCalls.MEMBERSHIP)
			{
				_viewStack.selectedPage=_entranceView;
				Global.externalCalls.tryLoadMembership();
			}
			else if (_mode == LoginModes.REGISTER_FROM_PARTNER)
			{
				_partnerUid=parameters.partnerUid;
				_registerView.partnerUid=_partnerUid;
				_viewStack.selectedPage=_registerView;
			}
			else
			{
				_entranceView.content.visible=true;
				_viewStack.selectedPage=_entranceView;
			}

		}

		private function login(login:String, password:String, skipRegistration:Boolean=false):void
		{
			_skipActivation=skipRegistration;
			_login=login;
			_pass=password;
			Global.isLocked=true;
			Global.authManager.loginEvent.addListenerIfHasNot(onLogin);
			Global.authManager.tryLogin(login, password);
		}

		private function onLoginFault(loginResult:LoginResultTO):void
		{
			Global.isLocked=false;
			Global.authManager.loginEvent.removeListenerIfHas(onLogin);

			var messages:Object={};
			messages[AuthenticationManager.ERROR_LOCAL_CONNECTION]=bundle.messages.localConnectionExists;
			messages[AuthenticationManager.ERROR_BAD_LOGIN]=bundle.messages.badLogin;
			messages[AuthenticationManager.ERROR_BAD_PASSW]=bundle.messages.badPassw;
			messages[AuthenticationManager.ERROR_LOGIN_EXISTS]=bundle.messages.loginExists;
			messages[AuthenticationManager.ERROR_EMAIL_EXISTS]=bundle.messages.emailExists;
			messages[AuthenticationManager.ERROR_LOGIN_BANNED]=bundle.messages.loginBanned;
			messages[AuthenticationManager.ERROR_LOGIN_DISABLED]=bundle.messages.loginDisabled;
			messages[AuthenticationManager.ERROR_IP_BANNED]=bundle.messages.ipBanned;
			messages[AuthenticationManager.ERROR_OUTDATED_SWF]=bundle.messages.outdatedSwf;
			messages[AuthenticationManager.ERROR_UNKNOWN]=bundle.messages.unknown;
			showError(messages[loginResult.reason]);
		}

		private function onActivationPlay(event:Object=null):void
		{
			closeModule();
			if(_previousLocId)
				Global.moduleManager.loadModule(_previousLocId, _previousLocParams);
		}

		private function onLogin(loginResult:LoginResultTO):void
		{
			Global.authManager.loginEvent.removeListenerIfHas(onLogin);
			Global.isLocked=false;
			Global.startupInfo.login=_login;
			Global.startupInfo.loginToken=loginResult.loginToken;
			if (!loginResult.active && !_skipActivation)
			{
				_activationView.login=_login;
				_viewStack.selectedPage=_activationView;
			}
			else
			{
				closeModule();
			}
		}

		private function showSuccess(message:String):void
		{
			_content.successMessage.field.text=message;
			_content.successMessage.visible=true;
			_content.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function showError(message:String):void
		{
			_content.errorMessage.errorField.text=message;
			_content.errorMessage.visible=true;
			_content.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function onMouseDown(event:MouseEvent):void
		{
			_content.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_content.errorMessage.visible=false;
			_content.successMessage.visible=false;
		}

		private function onTryLogin():void
		{
			login(_loginView.login, _loginView.passw);
		}

		private function onRegister(data:RegistrationData):void
		{
			_viewStack.selectedPage=_loginView;
			if (_mode == LoginModes.REGISTER_FROM_FAMILY)
			{
				closeModule();
			}
			else if (_mode == LoginModes.REGISTER_FROM_PARTNER)
			{
				new LoginService(onLoginFromPartner, onLoginFault).getPartnerLoginInfo(_partnerUid);
			}
			else
			{
				login(data.login, data.password, true);
			}
		}

		private function onLoginFromPartner(result:PartnerLoginCredentialsTO):void
		{
			login(result.login, _userEnteredPassword, true);
		}

		private function onRegisterBack():void
		{
			if (_mode == LoginModes.REGISTER_FROM_FAMILY)
			{
				closeModule();
			}else if(_lastView)
			{
				_viewStack.selectedPage=_lastView;
			}
			else
			{
				ExternalCalls.callExternal("ch_back");
				_viewStack.selectedPage=_entranceView;
			}

		}

		private function onRestorePassword():void
		{
			_viewStack.selectedPage=_restorePasswordView;
		}

		private function onRegisterSelect(event:Object=null):void
		{
			_lastView = _viewStack.selectedPage;
			_viewStack.selectedPage=_registerView;
		}

		private function onLoginSelect(event:Object=null):void
		{
			_viewStack.selectedPage=_loginView;
		}

		private function onGetConfig(result:ClientServerConfigTO):void
		{
			_config=result;
			_loginView.guestEnabled=result.guestsEnabled;
		}

		private function onDestroy(sender:Object):void
		{
			Global.stage.tabChildren=_tabChildren;
		}

		public function get config():Object
		{
			return _config;
		}

		public function get viewStack():ViewStackSwitcher
		{
			return _viewStack;
		}

		public function get activationView():ActivationView
		{
			return _activationView;
		}
	}

}

