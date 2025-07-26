package com.kavalok.dto.login
{
	import flash.net.registerClassAlias;
	
	public class PartnerLoginCredentialsTO 
	{

		public static function initialize() : void
		{
			registerClassAlias("com.kavalok.dto.login.PartnerLoginCredentialsTO", PartnerLoginCredentialsTO);
		}

		public var login : String;
		public var needRegistartion : Boolean;
		public var userId : int;

		public function PartnerLoginCredentialsTO()
		{
			super();
		}
		
	}
}