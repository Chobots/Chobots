package com.kavalok.services
{
	import com.kavalok.dto.stuff.StuffItemLightTO;
	
	public class StuffServiceNT extends Red5ServiceBase
	{
		public function StuffServiceNT(resultHandler:Function=null, faultHandler:Function=null)
		{
			super(resultHandler, faultHandler);
		}
		
		public function retriveItemWithColor(stuffName:String, color : int):void
		{
			doCall("retriveItemWithColor", arguments);
		}
		public function retriveItemByIdWithColor(stuffId:int, color : int, rainToken:String = null):void
		{
			doCall("retriveItemByIdWithColor", [stuffId, color, rainToken]);
		}
		public function retriveItem(stuffName:String):void
		{
			doCall("retriveItem", arguments);
		}
		public function retriveItemById(stuffId:int, rainToken:String = null):void
		{
			doCall("retriveItemById", [stuffId, rainToken]);
		}

		public function updateStuffItem(item : StuffItemLightTO) : void 
		{
			doCall("updateStuffItem", arguments);
		}
		
		public function getStuffTypes(shopName : String) : void
		{
			doCall("getStuffTypes", arguments);
		}
		
		public function removeItem(itemId:int):void
		{
			doCall("removeItem", arguments);
		}
		
		public function getItem(itemId:int):void
		{
			doCall("getItem", arguments);
		}

		public function getItemOfTheMonthType():void
		{
			doCall("getItemOfTheMonthType", arguments);
		}
		
		public function getStuffType(fileName:String):void
		{
			doCall("getStuffType", arguments);
		}

	}
}