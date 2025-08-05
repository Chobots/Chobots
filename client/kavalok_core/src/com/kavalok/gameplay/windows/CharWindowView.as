package com.kavalok.gameplay.windows
{
	import com.kavalok.Global;
	import com.kavalok.McCharWindow;
	import com.kavalok.char.Char;
	import com.kavalok.char.CharModel;
	import com.kavalok.char.commands.CharCommandBase;
	import com.kavalok.char.commands.FriendRequest;
	import com.kavalok.char.commands.IgnoreCommand;
	import com.kavalok.char.commands.KickOutCommand;
	import com.kavalok.char.commands.RemoveFriendCommand;
	import com.kavalok.char.commands.ReportCommand;
	import com.kavalok.char.commands.TeleportRequest;
	import com.kavalok.char.commands.UnIgnoreCommand;
	import com.kavalok.dto.stuff.StuffItemLightTO;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.ResourceSprite;
	import com.kavalok.gameplay.commands.RegisterGuestCommand;
	import com.kavalok.gameplay.controls.RectangleSprite;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.ui.LoadingSprite;
	import com.kavalok.ui.Window;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.NameRequirement;
	import com.kavalok.utils.SpriteTweaner;
	import com.kavalok.utils.Strings;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getDefinitionByName;

	public class CharWindowView extends Window
	{
		static private const SHOW_CHILD_FRAMES : uint = 5;
		static private const SMALL_MODEL_SCALE : Number = 0.28;
		static private const MODEL_SCALE : Number = 2.3;
	
		public var moodId:String = null;
		
		private var _char:Char;
		private var _charId:String;
		private var _content:McCharWindow;
		private var _bundle:ResourceBundle = Global.resourceBundles.kavalok;
		private var _playerCard:Sprite;
		
		private var _childViewSize : Point;
		private var _currentView : CharChildViewBase;
		private var _defaultChildViewHeight : int = 146;
		private var _defaultWindowHeight : int;
		private var _defaultPanelY : int;
		private var _loading:LoadingSprite;

		McFaces;
		
		static public function getWindowId(charId:String):String
		{
			return 'char_' + charId;
		}
		
		public function CharWindowView(charId:String)
		{
			_charId = charId;
			
			createContent();
			super(_content);
			
			_defaultWindowHeight = _content.height;
			_defaultPanelY = _content.buttonsPanel.y;
			_childViewSize = new Point(_content.childView.width, _content.childView.height);
			
			GraphUtils.removeChildren(_content.childView);
		}
		
		public function createContent():void
		{
			_content = new McCharWindow();
			_loading = new LoadingSprite(_content.cardMask.getBounds(_content));
			_content.addChild(_loading);
			
			if (!Global.startupInfo.widget)
			{
				_content.x = 25;
				_content.y = 25;
			}
			
			_content.nameField.text = _charId;
			_content.buttonsPanel.visible = false;
			_content.cardMask.visible = false;
			_content.charContainer.visible = false;
			_content.onlineInfoField.visible = false;
		}
		
		public function set char(char:Char):void
		{
			if (!_char)
			{
				Global.charManager.friends.refreshEvent.addListener(refresh);
				Global.charManager.ignores.refreshEvent.addListener(refresh);
				if (char.isUser)
					Global.charManager.playerCardChangeEvent.addListener(refreshPlayerCard);
				GraphUtils.detachFromDisplay(_loading);
			}
			
			_char = char;
			
			initContent();
			initStatus();
			createModel();
			adjustHeight();
			refresh();
			initButtons();
			refreshPlayerCard();
		}
		
		override public function onClose():void
		{
			if (_char)
			{
				Global.charManager.friends.refreshEvent.removeListener(refresh);
				Global.charManager.ignores.refreshEvent.removeListener(refresh);
				if (_char.isUser)
					Global.charManager.playerCardChangeEvent.removeListener(refreshPlayerCard);
			}
		}
		
		override public function get windowId():String
		{
			return getWindowId(_charId);
		}
		
		override public function get dragArea():InteractiveObject
		{
			return _content.headerButton;
		}
		
		
		private function initContent():void
		{
			_content.localeClip.gotoAndStop(_char.locale);
			_content.localeClip.visible = !_char.isUser;
			
			_content.charContainer.ageField.text = 
				Strings.substitute(Global.messages.charAge, isNaN(_char.age) ? '' : _char.age.toString());
				
			if (Global.startupInfo.widget == KavalokConstants.WIDGET_CHAR)
			{
				_content.buttonMode = true;
				_content.closeButton.visible = false;
				_content.addEventListener(MouseEvent.CLICK, Global.openHomePage);
			}
			
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			var item:ContextMenuItem = new ContextMenuItem("Copy embed to clipboard");
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyEmbed);
			menu.customItems.push(item);
			_content.contextMenu = menu;
		}
		
		private function refreshPlayerCard():void
		{
			if (_playerCard)
				GraphUtils.detachFromDisplay(_playerCard);
				
			_playerCard = new Sprite();
			_playerCard.x = _content.cardMask.x;
			_playerCard.y = _content.cardMask.y;
			_playerCard.scrollRect = new Rectangle(0, 0, _content.cardMask.width, _content.cardMask.height);
			GraphUtils.attachAfter(_playerCard, _content.background);
			
			var _card:StuffItemLightTO = _char.isUser
				? Global.charManager.playerCard
				: _char.playerCard;
			
			if (_card)
			{
				var stuff:ResourceSprite = _card.createModel();
				stuff.useView = false;
				stuff.fitToBounds = false;
				stuff.loadContent();
				_playerCard.addChild(stuff);
			}
			
			if (_char.isUser && !Global.startupInfo.widget && !Global.charManager.isGuest)
			{
				var clickArea:SimpleButton = new SimpleButton();
				clickArea.addEventListener(MouseEvent.CLICK, onCardClick);
				clickArea.hitTestState = new RectangleSprite(_content.cardMask.width, _content.cardMask.height);
				_playerCard.addChild(clickArea);
			}
		}
		
		private function onCardClick(e:MouseEvent):void
		{
			Global.frame.openCards();
			e.stopPropagation();
		}
		
		private function copyEmbed(e:Event):void
		{
			var widgetWidth:int = 235;
			var widgetHeight:int = 308;
			var swf:String = "http://chobots.com/game/CharWidget.swf";
			var urlPrefix:String = "http://www.chobots.com/game/";
			var login:String = _char.id;
			
			var pattern:String = '<object width="{0}" height="{1}">' + 
			'<param name="FlashVars" value="login={3}&urlPrefix={4}">' +
			'<param name="movie" value="{2}"/>' + 
			'<embed src="{2}" FlashVars="login={3}&urlPrefix={4}" width="{0}" height="{1}"/>' + 
			'</embed></object>'					
					
			var result:String = Strings.substitute(pattern,
				widgetWidth, widgetHeight, swf, login, urlPrefix);
			
			System.setClipboard(result);
		}
		
		public function set onlineInfo(value:String):void
		{
			 _content.onlineInfoField.text = value;
			 _content.onlineInfoField.visible = true;
		}
		
		private function initButtons():void
		{
			var panel:ButtonsPanel = _content.buttonsPanel;
			
			initButton(panel.chatButton, onChatClick, 'privateChat');
			initButton(panel.giftButton, onGiftClick, 'prezent');
			initButton(panel.tradeButton, onTradeClick, 'trade');
			initButton(panel.robotButton, onRobotClick, 'robot');
			
			bindCommand(panel.addButton, FriendRequest, 'addFriend');
			bindCommand(panel.removeButton, RemoveFriendCommand, 'removeFriend');
			bindCommand(panel.teleportButton, TeleportRequest, 'inviteToPlace');
			bindCommand(panel.ignoreButton, IgnoreCommand, 'ignoreUser');
			bindCommand(panel.unignoreButton, UnIgnoreCommand, 'unIgnoreUser');
			bindCommand(panel.kickButton, KickOutCommand, 'kickUser');
			bindCommand(panel.reportButton, ReportCommand, 'reportUser');
		}
		
		private function bindCommand(button:InteractiveObject, commandClass:Class, tip:String):void
		{
			var handler:Function = function():void
			{
				var command:CharCommandBase = new commandClass();
				command.char = _char;
				command.execute();
			}
			
			initButton(button, handler, tip);
		}
		
		public function initStatus():void
		{
			var charContainer:CharContainer = _content.charContainer;
			
			charContainer.visible = true;
			charContainer.agentSign.visible = _char.isAgent;
			charContainer.moderatorSign.visible = _char.isModerator;
			charContainer.passportSign.visible = _char.isCitizen;
			charContainer.charStatusField.visible = _char.isCitizen;
			charContainer.statusField.visible = (_char.isAgent || _char.isModerator);
			
			if(_char.isCitizen)
				_bundle.registerTextField(charContainer.charStatusField, 'statusCitizen');
			
			if(_char.isAgent)
				_bundle.registerTextField(charContainer.statusField, 'statusAgent');
			else if(_char.isModerator)
				_bundle.registerTextField(charContainer.statusField, 'statusModerator');
		}
		
		private function createModel():void
		{
			var charMask:Sprite = GraphUtils.createRectSprite(_content.cardMask.width, _content.cardMask.height);
			charMask.x = _content.cardMask.x;
			charMask.y = _content.cardMask.y;
			_content.addChild(charMask);
			_content.charContainer.mask = charMask;
			 
			var model:CharModel = new CharModel(_char);
			model.refresh();
			model.scale = MODEL_SCALE;
			_content.charContainer.charPosition.addChild(model);
			
//			if (moodId)
//			{
//				var head:Sprite = model.head;
//				var faceItems:Array = GraphUtils.getAllChildren(head, new NameRequirement('mcFace'));
//				for each (var faceItem:DisplayObject in faceItems)
//				{
//					GraphUtils.detachFromDisplay(faceItem);
//				}
//				
//				var faceClass:Class = Class(getDefinitionByName(moodId + 'Face'));
//				var face:Sprite = new faceClass();
//				face.removeChildAt(0); 
//				head.addChildAt(face, 1);
//			}
			
		}
		
		public function refresh():void
		{
			var isIgnored:Boolean = Global.charManager.ignores.contains(_char.id);
			var canBeIgnored:Boolean = !_char.isModerator;
				
			var locationExists:Boolean = Global.locationManager.locationExists;
			var panel:ButtonsPanel = _content.buttonsPanel;
			
			panel.visible = !Global.charManager.isGuest && !Global.startupInfo.widget;
			
			panel.chatButton.visible = !_char.isUser;	
			panel.giftButton.visible = !_char.isUser;	
			panel.addButton.visible = !_char.isUser && !isFriend && !_char.isGuest;
			panel.removeButton.visible = !_char.isUser && isFriend;
			panel.reportButton.visible = !_char.isUser && !_char.isGuest;
			panel.teleportButton.visible = !_char.isUser;
			panel.ignoreButton.visible = !_char.isUser && !isFriend && !isIgnored && canBeIgnored;
			panel.unignoreButton.visible = !_char.isUser && isIgnored;
			panel.kickButton.visible = (Global.charManager.isModerator || Global.superUser) && !_char.isUser;
			panel.tradeButton.visible = !_char.isUser;
			panel.robotButton.visible = !_char.isUser && _char.hasRobot;
			
			GraphUtils.setBtnEnabled(panel.addButton,
				acceptRequests);
			
			GraphUtils.setBtnEnabled(panel.chatButton, chatButtonEnabled);
			
			GraphUtils.setBtnEnabled(panel.giftButton,
				!(_currentView is GiftView ) && acceptRequests);
			
			GraphUtils.setBtnEnabled(panel.robotButton,
				!(_currentView is RobotView ));
			
			GraphUtils.setBtnEnabled(panel.teleportButton,
				_char.isOnline && acceptRequests);

			GraphUtils.setBtnEnabled(panel.tradeButton,
				_char.server == Global.loginManager.server && acceptRequests);
		}
		
		public function get isFriend():Boolean
		{
			return Global.charManager.friends.contains(_char.id);
		}
		
		public function get acceptRequests():Boolean
		{
			 return _char.acceptRequests || isFriend || _char.isUser
			 	|| Global.superUser || Global.charManager.isModerator;
		}
		
		private function get chatButtonEnabled():Boolean
		{
			return !_char.isUser && _char.isOnline && acceptRequests
				&& !(_currentView is PrivateChatView);
		}
		
		public function showChat(force:Boolean = false) : void
		{
			if(chatButtonEnabled || force && !(_currentView is PrivateChatView))
				showChildView(new PrivateChatView(_char.id, _char.userId));
		}
		
		override public function set alpha(value:Number):void
		{
			var items : Array = [_content.background, _content.childView, _content.buttonsPanel];
			for each(var object : DisplayObject in items)
			{
				object.alpha = value;
			}
		}
		
		private function onChatClick(event : MouseEvent) : void
		{
			showChat();
		}
		
		private function onTradeClick(event : MouseEvent) : void
		{
			if (Global.charManager.isGuest || Global.charManager.isNotActivated)
			{
				new RegisterGuestCommand().execute();
			}
			else
			{
				TradeWindowView.showWindow(_char.id, _char.userId, true);
			}
		}
		
		private function onGiftClick(event : MouseEvent) : void
		{
			if (Global.charManager.isGuest || Global.charManager.isNotActivated)
				new RegisterGuestCommand().execute();
			else
				showChildView(new GiftView(_char.id, _char.userId));
		}
		
		private function onRobotClick(event : MouseEvent) : void
		{
			showChildView(new RobotView(_char, acceptRequests));
		}

		private function showChildView(view : CharChildViewBase) : void
		{
			if(_currentView == null)
			{
				if (Global.performanceManager.quality != 0)
				{
					var properties:Object = {scaleX : SMALL_MODEL_SCALE, scaleY : SMALL_MODEL_SCALE}; 
					new SpriteTweaner(_content.charContainer, properties, SHOW_CHILD_FRAMES, null, onTweenEnd);
					_content.childView.visible = false;
				}
				else
				{
					_content.charContainer.scaleX = SMALL_MODEL_SCALE;
					_content.charContainer.scaleY = SMALL_MODEL_SCALE;
				}
				_playerCard.visible = false;
			}
			else
			{
				_currentView.heightChanging.removeListener(onChildHeightChanging);
				_content.childView.removeChild(_currentView.content);
				_currentView.destroy();
			}
			_currentView = view;
			_currentView.heightChanging.addListener(onChildHeightChanging);
			_content.childView.addChild(_currentView.content);
			adjustHeight();
			GraphUtils.claimBounds(_content, KavalokConstants.SCREEN_RECT)
			_currentView.initialize();
			refresh();
		}
		
		private function onChildHeightChanging(newHeight : Number = NaN) : void
		{
			adjustHeight(newHeight);
		}
		
		private function adjustHeight(newHeight : Number = NaN) : void
		{
			var childHeight:int = isNaN(newHeight) ? _defaultChildViewHeight : newHeight; 
			_content.background.height = _defaultWindowHeight - _defaultChildViewHeight
				+ childHeight;
			_content.buttonsPanel.y = _defaultPanelY + childHeight - _defaultChildViewHeight;
			GraphUtils.claimBounds(_content, KavalokConstants.SCREEN_RECT);
		}

		private function onTweenEnd(sender:Object) : void
		{
			_content.childView.visible = true;
		}
	}
}