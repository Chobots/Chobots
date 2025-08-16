package com.kavalok.admin.main
{
	import com.kavalok.admin.login.Login;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.login.AuthenticationManager;
	import com.kavalok.remoting.BaseDelegate;
	import com.kavalok.remoting.BaseRed5Delegate;
	import com.kavalok.remoting.RemoteConnection;
	import com.kavalok.login.LoginManager;
	
	import flash.events.NetStatusEvent;
	
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;
	
	import org.goverla.errors.NotImplementedError;

	public class MainViewBase extends ViewStack
	{

		public var login : com.kavalok.admin.login.Login;
		
		public function MainViewBase()
		{
			super();
			Localiztion.locale = "enUS";
			Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
			Localiztion.getBundle(ResourceBundles.KAVALOK);
			BaseDelegate.defaultFaultHandler = onServiceFault;
		}
		
		protected function onCreationComplete(event : FlexEvent) : void
		{
			BaseRed5Delegate.defaultConnectionUrl = LoginManager.buildRtmpUrl();
			BaseDelegate.defaultFaultHandler = onServiceFault;
			RemoteConnection.instance.isAdmin = true;
			RemoteConnection.instance.connectEvent.addListener(onConnect);
			RemoteConnection.instance.error.addListener(onError);
			RemoteConnection.instance.disconnectEvent.addListener(onDisconnect);
			RemoteConnection.instance.connect();
		}
		protected function onConnect() : void
		{
			login.visible = true;
			login.login.addListener(onTryLogin);
		}
		public function tryLogin(login : String, pass : String) : void
		{
			throw new NotImplementedError("abstract method must be implemented in superclass");
		}
		protected function onTryLogin(args : Array) : void
		{
			tryLogin(args[0], args[1]);
		}
		protected function onLoginFault(fault : Object = null) : void
		{
			Alert.show("Login error please try one more time");
		}
		protected function onLoginResult(result : String) : void
		{
			if(result == AuthenticationManager.SUCCESS)
			{
				selectedIndex = 1;
			}
			else
			{
				onLoginFault();
			}
		}
		private function onError(fault : NetStatusEvent) : void
		{
			Alert.show("Connection error " + fault.info.description);
		}
		private function onDisconnect() : void
		{
			// Return to login screen but hide the login form
			selectedIndex = 0;
			login.visible = false;
			Alert.show("Disconnected please refresh");
		}
		private function onServiceFault(fault : Object) : void
		{
			Alert.show("Service call error " + fault.description);
		}
	}
}