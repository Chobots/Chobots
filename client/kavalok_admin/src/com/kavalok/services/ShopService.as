package com.kavalok.services
{
	import com.kavalok.dto.shop.ShopAdminTO;
	
	public class ShopService extends Red5ServiceBase
	{
		public function ShopService(resultHandler:Function=null, faultHandler:Function=null)
		{
			super(resultHandler, faultHandler);
		}
		
		public function getShops():void
		{
			doCall("getShops", arguments);
		}
		
		public function saveShop(shop:ShopAdminTO):void
		{
			doCall("saveShop", arguments);
		}
	}
} 