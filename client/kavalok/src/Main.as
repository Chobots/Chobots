package
{
	import com.kavalok.Global;
	import com.kavalok.StartupInfo;
	import com.kavalok.utils.URLUtil;
	import com.kavalok.login.LoginManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;

	[SWF(width='900', height='510', backgroundColor='0x006699', framerate='24')]
	public class Main extends Sprite
	{
		
		public function Main()
		{
			super();
			Security.allowDomain('*');
			if (this.stage)
				initialize();
			else
				addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function traceInfo():void
		{
			trace(this);
			trace(this.loaderInfo.url);
			trace('[parameterInfo:]');

			for (var paramName:String in this.loaderInfo.parameters) {
				trace(paramName + ': ' + this.loaderInfo.parameters[paramName])
			}
		}
		
		private function initialize(e:Event = null):void
		{
			traceInfo();
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			var rtmpHost:String = loaderInfo.parameters.server;
			var info:StartupInfo = new StartupInfo();
			info.prefix = loaderInfo.parameters.guest;
			info.url = LoginManager.buildRtmpUrl();
			info.locale = loaderInfo.parameters.locale;
			info.partnerUid = loaderInfo.parameters.partnerUid;
			info.homeURL = loaderInfo.parameters.homeURL;
			info.version = loaderInfo.parameters.version;
			info.moduleId = loaderInfo.parameters.moduleId;
			
			info.mppc_src = loaderInfo.parameters.mppc_src;
			info.mppc_cid = loaderInfo.parameters.mppc_cid;
			info.mppc_keywords = loaderInfo.parameters.mppc_keywords;
			info.mppc_referrer = loaderInfo.parameters.mppc_referrer;
			info.mppc_activationUrl = loaderInfo.parameters.mppc_activationUrl
			info.mppc_partner = loaderInfo.parameters.mppc_partner;
			
			if (loaderInfo.parameters.hasOwnProperty('scale')) {
                Global.scale = loaderInfo.parameters.scale;
            }
			 
			Global.referer = loaderInfo.parameters.referer;
			
			var kavalok : Kavalok = new Kavalok(info, this);
		}
	}
}
