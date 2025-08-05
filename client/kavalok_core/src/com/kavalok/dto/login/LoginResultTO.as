package com.kavalok.dto.login
{
	import flash.net.registerClassAlias;
	
	public class LoginResultTO
	{
		public static function initialize() : void
		{
			registerClassAlias("com.kavalok.dto.login.LoginResultTO", LoginResultTO);
		}

		public var success : Boolean;
		public var active : Boolean;
		public var reason : String;
		public var age : Number;
		public var loginToken : String;

		public function LoginResultTO()
		{
		}

	}
}