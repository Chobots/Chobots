package com.kavalok.services
{
	import com.kavalok.remoting.BaseRed5Delegate;

	public class SystemService extends BaseRed5Delegate
	{
		public function SystemService(resultHandler:Function=null, faultHandler:Function = null)
		{
			super(resultHandler, faultHandler);
		}
		
		public function getServerProperties():void
		{
			doCall("getServerProperties", arguments);
		}
		
		public function clientTick():void
		{
			doCall("clientTick", arguments);
		}
		
		public function getSystemDate():void
		{
			doCall("getSystemDate", arguments);
		}
	}
}

