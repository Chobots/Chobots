package com.kavalok.services
{

	public class MagicServiceNT extends Red5ServiceBase
	{
		public function MagicServiceNT(resultHandler:Function = null, faultHandler:Function = null)
		{
			super(resultHandler, faultHandler);
		}

		public function getMagicPeriod():void
		{
			doCall("getMagicPeriod", arguments);
		}
		
		public function updateMagicDate():void
		{
			doCall("updateMagicDate", arguments);
		}
		
		public function executeMagicRain():void
		{
			doCall("executeMagicRain", arguments);
		}
	}
}