package com.kavalok
{
	import com.kavalok.dto.login.MarketingInfoTO;

	public class StartupInfo
	{
		public var url:String;
		public var prefix:String = null;
		public var login:String;
		public var server:String;
		public var loginToken:String;
		public var moduleId:String;
		public var moduleParams:Object;
		public var isBot:Boolean = false;
		public var debugMode:Boolean = false;
		public var locale:String;
		public var errorLogEnabled:Boolean = false;
		public var widget:String = null;
		public var partnerUid:String;
		public var homeURL:String;
		public var version:String;
		
		public var mppc_src:String;
		public var mppc_cid:String;
		public var mppc_keywords:String;
		public var mppc_referrer:String;
		public var mppc_activationUrl:String
		public var mppc_partner:String;
		
		public function get redirectURL():String
		{
			return homeURL || mppc_activationUrl || url;
		}
		
		public function get marketingInfo():MarketingInfoTO
		{
			var result:MarketingInfoTO = new MarketingInfoTO();

			result.source = Global.startupInfo.mppc_src;
			result.campaign = Global.startupInfo.mppc_cid;
			result.keywords = Global.startupInfo.mppc_keywords;
			result.referrer = Global.startupInfo.mppc_referrer;
			result.activationUrl = redirectURL;
			result.partner = Global.startupInfo.mppc_partner;
			return result;
		}

	}
}