package com.kavalok.gameplay.commands
{
	import com.kavalok.Global;
	import com.kavalok.char.Stuffs;
	import com.kavalok.dto.stuff.StuffItemLightTO;
	import com.kavalok.messenger.commands.GiftMessage;
	import com.kavalok.services.StuffServiceNT;
	
	public class RetriveStuffByIdCommand
	{
		private var _itemId:int;
		private var _from:String;
		private var _color:Number;
		private var _rainToken:String;
		
		public function RetriveStuffByIdCommand(id:int, from:String, color : Number = NaN, rainToken:String = null)
		{
			_itemId = id;
			_from = from;
			_color = color;
			_rainToken = rainToken;
		}
		
		public function execute():void
		{
			Global.isLocked = true;
			if(isNaN(_color))
				new StuffServiceNT(onResult).retriveItemById(_itemId, _rainToken);
			else
				new StuffServiceNT(onResult).retriveItemByIdWithColor(_itemId, _color, _rainToken);
			
		}
		
		private function onResult(item:StuffItemLightTO):void
		{
			stuffs.addItem(item);
			
			var message:GiftMessage = new GiftMessage();
			message.itemId = item.id;
			message.sender = _from;
			message.execute();
			
			Global.isLocked = false;
		}
		
		public function get stuffs():Stuffs
		{
			 return Global.charManager.stuffs;
		}
	}
}