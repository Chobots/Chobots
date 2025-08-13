package com.kavalok.gameplay.frame
{
	import com.kavalok.Global;
	import com.kavalok.chat.ChatLog;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.events.EventSender;
	import com.kavalok.events.TargetEvent;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.ToolTips;
	import com.kavalok.gameplay.controls.TextScroller;
	import com.kavalok.gameplay.notifications.INotification;
	import com.kavalok.utils.Strings;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ChatLogView
	{
		private static const MAX_HISTORY:int = 60;
		private static const MASK_OVERSCAN:int = 20000;
		
		private var _chooseRecipient:EventSender = new EventSender(TargetEvent);
		private var _content:ChatLog;
		private var _scroller:TextScroller;
		private var _open:Boolean;
		private var _chatHistory:Array = [];
		private var _mask:Sprite;
		private var _openHeight:Number;
		private var _closedHeight:Number = 11;
		private var _openChange:EventSender = new EventSender(Boolean);
		
		public function ChatLogView(content:ChatLog)
		{
			_content = content;
			_mask = new Sprite();
			_content.addChild(_mask);
			_content.mask = _mask;

			_openHeight = Math.min(_content.chatTextField.height, _content.mcVertScroll.height) + 14;
			redrawMask(_closedHeight);
			
			_content.openCloseButton.addEventListener(MouseEvent.CLICK, onOpenCloseClick);
			ToolTips.registerObject(_content.openCloseButton, "chatHistory", ResourceBundles.KAVALOK);
			
			_scroller = new TextScroller(_content.mcVertScroll, _content.chatTextField);
		}
		
		public function get closedHeight():Number { return _closedHeight; }
		public function get open():Boolean { return _open; }
		public function get openChange():EventSender { return _openChange; }
		public function get openHeight():Number { return _openHeight; }
		public function get chooseRecipient():EventSender { return _chooseRecipient; }
		
		public function set open(value:Boolean):void
		{
			if (_open != value)
			{
				_open = value;
				redrawMask(value ? _openHeight : _closedHeight);
				if (_open) refresh();
				_openChange.sendEvent(_open);
			}
		}
		
		public function showNotification(notification:INotification):void
		{
			if (_chatHistory.length >= MAX_HISTORY)
				_chatHistory.shift();
			
			var messageText:String = getMessageText(notification);
			_chatHistory.push(messageText);
			
			if (_open) refresh();
		}
		
		private function refresh():void
		{
			_content.chatTextField.htmlText = _chatHistory.join('\n');
			_scroller.position = 1;
			_scroller.updateScrollerVisible();
		}
		
		private function getMessageText(notification:INotification):String
		{
			var isMy:Boolean = (notification.fromUserId == Global.charManager.userId);
			var format:String = isMy ? KavalokConstants.MY_MESSAGE_FORMAT : KavalokConstants.OTHERS_MESSAGE_FORMAT;
			return Strings.substitute(format, notification.fromLogin, notification.getText());
		}
		
		private function redrawMask(height:Number):void
		{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x000000, 1);
			var bounds:Rectangle = _content.getBounds(_content);
			var maskHeight:Number = Math.max(0, Math.min(height, bounds.height));
			_mask.graphics.drawRect(-MASK_OVERSCAN / 2 + bounds.x, bounds.y, MASK_OVERSCAN, maskHeight);
			_mask.graphics.endFill();
		}
		
		private function onOpenCloseClick(event:MouseEvent):void
		{
			open = !open;
		}
	}
}