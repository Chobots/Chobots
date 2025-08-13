package com.kavalok.gameplay.frame
{
	import com.kavalok.Global;
	import com.kavalok.chat.MessageWindow;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.dialogs.Dialogs;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.ToolTips;
	import com.kavalok.gameplay.commands.RegisterGuestCommand;
	import com.kavalok.gameplay.controls.ToggleButton;
	import com.kavalok.gameplay.frame.safeChat.SafeChatInputView;
	import com.kavalok.gameplay.notifications.Notification;
	import com.kavalok.utils.AdminConsole;
	import com.kavalok.utils.SpriteTweaner;
	import com.kavalok.utils.Strings;
	
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	public class MessageWindowView 
	{
		private static const MAX_CHARS:int = KavalokConstants.MAX_CHAT_CHARS;
		private static const SAFE_CHAT_ADD_HEIGHT : Number = 6;
		private static const SAFE_CHAT_OPEN_ADD_HEIGHT : Number = 60;
		private static const TWEEN_FRAMES:uint = 5;
		

		private var _chatLogView : ChatLogView;
		private var _safeChatInput : SafeChatInputView;
		
		private var _toOpen : Boolean = false;
		private var _content : MessageWindow;
		private var _chatSelect : ToggleButton;
		private var _unsafePosition : Number;
		private var _safe : Boolean;
		
		private var _baseChatLogY:Number = NaN;
		public function MessageWindowView(content:MessageWindow)
		{
			_content = content;
			_unsafePosition = _content.y;
			
			_safeChatInput = new SafeChatInputView(_content.safeChat);
			_safeChatInput.openEvent.addListener(onSafeChatOpen);
			
			_chatLogView = new ChatLogView(_content.chatLogWindow.mc_chatLog);
			_chatLogView.openChange.addListener(onChatLogOpenChange);
			// remember base position of the chat log window for toggling
			_baseChatLogY = _content.chatLogWindow.y;
			content.chatLogWindow.gotoAndStop(content.chatLogWindow.totalFrames);
			content.sendTextField.text = "";
			content.sendTextField.maxChars = MAX_CHARS;
			_content.sendTextField.restrict = Global.serverProperties.charSet;
			content.sendTextField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			content.sendButton.addEventListener(MouseEvent.CLICK, onSendClick);
			

			_chatSelect = new ToggleButton(_content.safeChatButton);
			_content.safeChatButton.addEventListener(MouseEvent.CLICK, onSafeChatClick);
			_content.safeChat.visible = false;

			Global.notifications.receiveNotificationEvent.addListener(onReceiveNotification);
			
			Global.stage.addEventListener(KeyboardEvent.KEY_UP, onApplicationKeyUp, false, 0, true);
			Global.root.addEventListener(MouseEvent.CLICK, onApplicationClick, false, 0, true);

			ToolTips.registerObject(content.sendButton, "sendMessage", ResourceBundles.KAVALOK);
			
			showSafe(!Global.notifications.chatEnabled);
				
			Global.notifications.chatEnabledChange.addListener(onChatEnabledChange);
			
			refresh();
		}
		
		public function get open() : Boolean
		{
			return _chatLogView.open;
		}
		
		public function set open(value : Boolean) : void
		{
			_chatLogView.open = value;
		}
		
		private function onSafeChatOpen(value : Boolean) : void
		{
			var newPosition : int = 
				value ? _unsafePosition - SAFE_CHAT_OPEN_ADD_HEIGHT : _unsafePosition - SAFE_CHAT_ADD_HEIGHT;
			resize(newPosition);
		}
		
		private function onChatEnabledChange(value : Boolean) : void
		{
			showSafe(!value);
		}
		
		private function resize(newPosition : int) : void
		{
			new SpriteTweaner(_content, {y : newPosition}, TWEEN_FRAMES);
		}
		
		private function onChatLogOpenChange(isOpen:Boolean):void
		{
			// Move only the chat.ChatLogWindow up to reveal history
			var targetY:Number = isOpen ? (_baseChatLogY - (_chatLogView.openHeight - _chatLogView.closedHeight)) : _baseChatLogY;
			new SpriteTweaner(_content.chatLogWindow, { y: targetY }, TWEEN_FRAMES);
		}
		
		private function showSafe(value : Boolean) : void
		{
			_content.safeChat.visible = value;
			_content.sendTextField.visible = !value;
			_content.textInputBackground.visible = !value;
			_chatSelect.toggle = value;
			
			var position : Number = value ? _unsafePosition - SAFE_CHAT_ADD_HEIGHT : _unsafePosition;
			resize(position);
			_safe = value;
			if(!value)
				_safeChatInput.clear();
		}

		public function setFocus() : void
		{
			_content.stage.focus = _content.sendTextField;
		}

		private function onSafeChatClick(event : MouseEvent) : void
		{
			if (Global.charManager.isGuest || Global.charManager.isNotActivated)
			{
				new RegisterGuestCommand().execute();
				_chatSelect.toggle = true;
			}	
			else if (Global.charManager.serverChatDisabled)
			{
				Dialogs.showOkDialog(Global.messages.safeModeTextChat);
				_chatSelect.toggle = true;
			}
			else if (!Global.notifications.chatEnabled)
			{
				Dialogs.showOkDialog(Global.messages.chatDisabled);
				_chatSelect.toggle = true;
			}
			
			else
			{
				showSafe(_chatSelect.toggle);
			}
			
			refresh();
		}
		
		private function refresh():void
		{
			var messageId:String = (_chatSelect.toggle)
				? "fullChat"
				: "safeChat";
				
			ToolTips.registerObject(_content.safeChatButton, messageId, ResourceBundles.KAVALOK);
		}
			
		
		
		private function onReceiveNotification(notification : Notification) : void
		{
			if(notification.toLogin == null)
			{
				_chatLogView.showNotification(notification);
			}
		}
		
		private function send() : void
		{
			var text : String = Strings.trim(_content.sendTextField.text);
			text = Strings.removeHTML(text);
			if((!_safe && text == "") || (_safe && _safeChatInput.message.length == 0))
				return;
				
			if (Global.superUser && text.charAt(0) == '#')
			{
				new AdminConsole().process(text);
				System.setClipboard(text);
				_content.sendTextField.text = '';
			}
			else
			{
				var message : Object = _safe ? _safeChatInput.message : text;
				var notification : Notification = new Notification(Global.charManager.charId, Global.charManager.userId, message);
				_content.sendTextField.text = "";
				_safeChatInput.clear();
				Global.notifications.sendNotification(notification);
			}
			
//			var timer:Timer = new Timer(20);
//			timer.addEventListener(TimerEvent.TIMER, 
//				function(e:TimerEvent):void {
//					notification.message = text + String(int(Math.random() * 1000));
//					Global.notifications.sendNotification(notification);
//				});
//			timer.start();
		}
		
		private function onApplicationKeyUp(event : KeyboardEvent) : void
		{
			var focus : InteractiveObject = _content.stage.focus;
			if(event.keyCode == Keyboard.ENTER && (focus == null || !(focus is TextField)))
			{
				if(_chatSelect.toggle)
				{
					if(_safeChatInput.message.length > 0)
					{
						send();
					}
				}
				else
				{
					setFocus();
				}
			}
		}
		private function onApplicationClick(event : MouseEvent) : void
		{
			if(!_content.hitTestPoint(event.stageX, event.stageY))
			{
				open = false;
				_safeChatInput.destroyCurrentGroup();
			}
			_toOpen = false;
		}
		private function onChangeState() : void
		{
			open = !open;
		}
		
		private function onKeyUp(event : KeyboardEvent) : void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				send();
			}
		}

		private function onSendClick(event : MouseEvent) : void
		{
			send();
			
		}
	
		
		
	}
}