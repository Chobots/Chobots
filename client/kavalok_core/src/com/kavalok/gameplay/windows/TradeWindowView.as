package com.kavalok.gameplay.windows
{
	import com.kavalok.Global;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.dialogs.Dialogs;
	import com.kavalok.dto.stuff.StuffItemLightTO;
	import com.kavalok.gameplay.ToolTips;
	import com.kavalok.gameplay.controls.StuffListScroller;
	import com.kavalok.gameplay.frame.bag.StuffList;
	import com.kavalok.gameplay.frame.bag.StuffSprite;
	import com.kavalok.gameplay.trade.TradeClient;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.messenger.commands.TradeMessage;
	import com.kavalok.services.MessageService;
	import com.kavalok.ui.Window;
	import com.kavalok.utils.Arrays;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.comparing.PropertyCompareRequirement;
	import com.kavalok.utils.converting.ConstructorConverter;
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	public class TradeWindowView extends Window
	{
		public static const ID : String = "tradeWindow";
		private static const REMOTE_ID_FORMAT : String = "trade|{0}|{1}";

		private static var bundle : ResourceBundle = Localiztion.getBundle(ResourceBundles.KAVALOK);
		private static var remoteId:String;
		
		public static function showWindow(charId : String, userId : Number, sendMessage : Boolean) : void
		{
			var window : TradeWindowView = TradeWindowView(Global.windowManager.getWindow(TradeWindowView.ID));
			if(window)
			{
				Global.windowManager.activateWindow(window);
				if(window.partner != charId)
				{
					Dialogs.showOkDialog(bundle.getMessage("tradeCannotOpen2Windows"));
				}
			}
			else
			{
				window = new TradeWindowView(charId);
				Global.windowManager.showWindow(window);
				if(sendMessage)
				{
					var message : TradeMessage = new TradeMessage();
					message.remoteId = remoteId;
					new MessageService().sendCommand(userId, message);
				}
			}
			
		}

		private var _stuffList : StuffList;
		private var _myTradeList : StuffList;
		private var _myScroller : StuffListScroller;
		private var _hisTradeList : StuffList;
		private var _hisScroller : StuffListScroller;
		private var _content : McTradeWindow = new McTradeWindow();
		private var _partner : String;
		private var _oneAccepted : Boolean;
		private var _finished : Boolean;
		private var _client:TradeClient;
		
		public function TradeWindowView(partner : String)
		{
			super(_content);
			Dialogs.centerWindow(_content);
			_partner = partner;
			
			var users : Array = [userId, partner];
			users.sort();
			remoteId = Strings.substitute(REMOTE_ID_FORMAT, users[0], users[1]);
			
			_client = new TradeClient();
			_client.connectEvent.addListener(onConnect);
			_client.onCharConnect = onCharConnect;
			_client.onCharDisconnect = onCharDisconnect;
			_client.rAddItem = rAddItem;
			_client.rRemoveItem = rRemoveItem;
			_client.rAccept = rAccept;
			_client.connect(remoteId);
			
			_content.traderNameField.text = partner;
			GraphUtils.setBtnEnabled(_content.acceptButton, false);
			
			_content.acceptButton.addEventListener(MouseEvent.CLICK, onAccept);

			bundle.registerTextField(_content.partnerField, "tradeWaiting");
			bundle.registerButton(_content.acceptButton, "tradeAccept");
			
			_stuffList = new StuffList(_content.myStuff, 1, 4);
			
			_myTradeList = new StuffList(_content.myTradeStuff, 3, 3);
			_myScroller = new StuffListScroller(_content.myScroller, _myTradeList);
			_hisTradeList = new StuffList(_content.hisTradeStuff, 3, 3);
			_hisScroller = new StuffListScroller(_content.hisScroller, _hisTradeList);
			
			var items : Array = Arrays.getConverted(Global.charManager.stuffs.getGiftableItems()	
				, new ConstructorConverter(StuffSprite));
			_stuffList.setItems(items);
			
			_content.nothingToTrade.visible = items.length == 0;
			
			_stuffList.selectedItemChange.addListener(onSelectedAddItem);
			_myTradeList.selectedItemChange.addListener(onSelectedRemoveItem);

			ToolTips.registerObject(_stuffList.content, "tradeCannotChangeNotConnected", ResourceBundles.KAVALOK);
			ToolTips.registerObject(_myTradeList.content, "tradeCannotChangeNotConnected", ResourceBundles.KAVALOK);

			Global.charManager.stuffs.refreshEvent.addListener(onStuffChange);
			
			_content.nextButton.addEventListener(MouseEvent.CLICK, onNextClick);			
			_content.prevButton.addEventListener(MouseEvent.CLICK, onPreviousClick);
			disable();
			refreshButtons();			
			
		}
		
		override public function get windowId():String
		{
			return ID;
		}

		public function get partner():String
		{
			return _partner;
		}

		override public function get dragArea():InteractiveObject
		{
			return _content.headerButton;
		}
		
		override public function onClose():void
		{
			if (Global.charManager.stuffs.refreshEvent.hasListener(onStuffChange)) {
				Global.charManager.stuffs.refreshEvent.removeListener(onStuffChange);
			}
			_client.disconnect();
		}
		
		public function onConnect():void
		{
			if(_client.numConnectedChars > 1)
			{
				enable();
			}
		}
		
		private function onCharDisconnect(charId:String):void
		{
			if(!_finished)
			{
				Dialogs.showOkDialog(partner + " " + bundle.getMessage("tradeOtherExit"));
				Global.windowManager.closeWindow(this);
			}
		}
		
		private function onCharConnect(charId:String):void
		{
			if(_client.numConnectedChars > 1)
			{
				enable();
			}
		}
		
		public function rAccept(charId : String) : void
		{
			if(_oneAccepted)
			{
				_finished = true;
				Dialogs.showOkDialog(bundle.getMessage("tradeSuccessfull"));
				Global.charManager.stuffs.refresh();
				Global.windowManager.closeWindow(this);
				return;
			}
			
			_oneAccepted = true;
			disable();
			ToolTips.registerObject(_stuffList.content, "tradeCannotChangeItems", ResourceBundles.KAVALOK);
			ToolTips.registerObject(_myTradeList.content, "tradeCannotChangeItems", ResourceBundles.KAVALOK);
			if(charId == _partner)
			{
				bundle.registerTextField(_content.partnerField, "tradeAccepted");
			}
		}

		public function rRemoveItem(charId : String, item : StuffItemLightTO) : void
		{
			var list : StuffList = charId == userId ? _myTradeList:_hisTradeList;
			var viewInfo : StuffSprite = StuffSprite(Arrays.firstByRequirement(list.items
				, new PropertyCompareRequirement("item.id", item.id)));
			list.removeItem(viewInfo);
			if(userId == charId)
			{
				_stuffList.addItem(new StuffSprite(item));
				refreshButtons();
			}
		}

		public function rAddItem(charId : String, item : StuffItemLightTO) : void
		{
			var list : StuffList = charId == userId ? _myTradeList:_hisTradeList;
			list.addItem(new StuffSprite(item));
			if(charId == userId)
			{
				var viewInfo : StuffSprite = StuffSprite(Arrays.firstByRequirement(_stuffList.items
					, new PropertyCompareRequirement("item.id", item.id)));
				_stuffList.removeItem(viewInfo);
				refreshButtons();
			}
		}
		
		private function disable() : void
		{
			GraphUtils.makeGray(_stuffList.content);
		}
		private function onSelectedRemoveItem() : void
		{
			if(_oneAccepted || _client.numConnectedChars <= 1)
				return;
			if(_myTradeList.selectedItem)
			{
				_client.send("rRemoveItem", userId, _myTradeList.selectedItem.item);
			}
		}
		private function onSelectedAddItem() : void
		{
			if(_oneAccepted || _client.numConnectedChars <= 1)
				return;
			if(_stuffList.selectedItem)
			{
				_client.send("rAddItem", userId, _stuffList.selectedItem.item);
			}
		}
		private function onStuffChange(item : Object = null) : void
		{
			if(!_finished)
			{
				Dialogs.showOkDialog(bundle.getMessage("tradeItemsChanged"));
				Global.windowManager.closeWindow(this);
			}
		}
		private function onNextClick(event : MouseEvent) : void
		{
			_stuffList.pageIndex++;
			refreshButtons();
		}
		private function onPreviousClick(event : MouseEvent) : void
		{
			_stuffList.pageIndex--;
			refreshButtons();
		}

		private function refreshButtons() : void
		{
			GraphUtils.setBtnEnabled(_content.acceptButton, _myTradeList.items.length > 0);
			GraphUtils.setBtnEnabled(_content.prevButton, _stuffList.backEnabled);
			GraphUtils.setBtnEnabled(_content.nextButton, _stuffList.nextEnabled);
		}
		private function onAccept(event : MouseEvent) : void
		{
			_client.send("rAccept", userId);
			GraphUtils.setBtnEnabled(_content.acceptButton, false);
			GraphUtils.setBtnEnabled(_content.prevButton, false);
			GraphUtils.setBtnEnabled(_content.nextButton, false);
			bundle.registerButton(_content.acceptButton, "tradeAccepted");
		}
		
		private function enable() : void
		{
			ToolTips.registerObject(_stuffList.content, "tradeClickToTrade", ResourceBundles.KAVALOK);
			ToolTips.registerObject(_myTradeList.content, "tradeClickToRemove", ResourceBundles.KAVALOK);
			bundle.registerTextField(_content.partnerField, "tradeTraiding");
			refreshButtons();
			_stuffList.content.filters = [];
		}
		
		public function get userId():String
		{
			 return Global.charManager.charId;
		}
		
		
	}
}