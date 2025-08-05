package com.kavalok.messenger.commands
{
	import com.kavalok.Global;
	import com.kavalok.char.Stuffs;
	import com.kavalok.constants.StuffTypes;
	import com.kavalok.dto.stuff.StuffItemLightTO;
	import com.kavalok.gameplay.ResourceSprite;
	import com.kavalok.gameplay.commands.CitizenWarningCommand;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.messenger.McPresentWindow;
	import com.kavalok.services.StuffServiceNT;
	import com.kavalok.utils.GraphUtils;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class StuffMessageBase extends MessageBase
	{
		public var itemId:int;
		
		private var _bundle:ResourceBundle = Global.resourceBundles.kavalok;
		private var _item:StuffItemLightTO;
		
		public function StuffMessageBase():void
		{
		}
		
		private function onGetItem(result:StuffItemLightTO):void
		{
			trace("StuffMessageBase.onGetItem: result.color = " + result.color + " (hex: 0x" + result.color.toString(16) + "), result.id = " + result.id);
			Global.charManager.stuffs.addItem(result)
			
			// Use the result directly instead of getting from inventory to preserve the correct color
			_item = result;
			trace("StuffMessageBase.onGetItem: Using result directly, _item.color = " + _item.color + " (hex: 0x" + _item.color.toString(16) + "), _item.id = " + _item.id);
			
			if (_item)
				showStuff(sender, getText());
		}
		
		override public function getText():String
		{
			return Global.messages.giftMessage;
		}
		
		override public function getIcon():Class
		{
			return McMsgStuffIcon;
		}
		
		override public function show():void
		{
			new StuffServiceNT(onGetItem).getItem(itemId);
		}
		
		private function onUseClick(e:MouseEvent):void
		{
			if (_item.premium && !Global.charManager.isCitizen && _item.type != StuffTypes.STUFF)
			{
				new CitizenWarningCommand("premiumClothes", null).execute();
			}
			else if (_item.type == StuffTypes.PLAYERCARD)
			{
				Global.charManager.playerCard = _item;
			}
			else
			{
				stuffs.useItem(_item);
			}
			
			
			closeDialog();
			_item = null;
		}
		
		protected function showStuff(
			caption:String,
			text:String,
			onClose:Function = null):void
		{
			//-- create window
			var view:McPresentWindow  = new McPresentWindow();
			view.captionField.text = String(caption);
			view.messageField.text = String(text);
			
			view.closeButton.addEventListener(MouseEvent.CLICK, closeDialog);
			view.useButton.addEventListener(MouseEvent.CLICK, onUseClick);
			
			if (_item.type == StuffTypes.CLOTHES)
			{
				_bundle.registerButton(view.useButton, 'giftClothesUse');
				_bundle.registerButton(view.closeButton, 'giftClothesPut');
			}
			else if (_item.type == StuffTypes.FURNITURE)
			{
				view.useButton.visible = false;
				_bundle.registerButton(view.closeButton, 'ok');
			}
			else
			{
				_bundle.registerButton(view.useButton, 'giftStuffUse');
				_bundle.registerButton(view.closeButton, 'giftStuffPut');
			}
				 
			//-- createModel
			var model:ResourceSprite = _item.createModel();
			model.loadContent();
			GraphUtils.scale(model, view.stuffRect.height, view.stuffRect.width)
			view.addChild(model);
			
			var modelRect:Rectangle = model.getBounds(view);
			var positionRect:Rectangle = view.stuffRect.getBounds(view);
			model.x += (positionRect.x + 0.5 * positionRect.width)
				- (modelRect.x + 0.5 * modelRect.width)
			model.y += (positionRect.y + 0.5 * positionRect.height)
				- (modelRect.y + 0.5 * modelRect.height);
			view.removeChild(view.stuffRect);
			//--
			
			showDialog(view); 
		}
		
		private function get stuffs():Stuffs
		{
			 return Global.charManager.stuffs;
		}
		
	}
}