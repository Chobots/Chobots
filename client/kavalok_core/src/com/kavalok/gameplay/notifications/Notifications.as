package com.kavalok.gameplay.notifications
{

	import com.kavalok.Global;
	import com.kavalok.collections.ArrayList;
	import com.kavalok.events.EventSender;
	import com.kavalok.messenger.commands.PrivateMessage;
	import com.kavalok.services.MessageService;
	
	import flash.utils.Dictionary;
		
	
	public class Notifications
	{
		static private const STACK_LENGTH:int = 20;
		
		private var _history : Dictionary = new Dictionary();
		private var _receiveNotificationEvent : EventSender = new EventSender(Notification);
		private var _chatEnabledChange : EventSender = new EventSender(Boolean);
		private var _chatEnabled : Boolean = true;
		private var _stack:Array = [];

		public function get chatEnabledChange() : EventSender
		{
			return _chatEnabledChange;
		}
		
		public function get stack():Array
		{
			return _stack;
		}
		
		public function get receiveNotificationEvent() : EventSender
		{
			return _receiveNotificationEvent;
		}
		
		public function set chatEnabled(value : Boolean) : void
		{
			if(_chatEnabled != value)
			{
				_chatEnabled = value;
				chatEnabledChange.sendEvent(value);
			}
		}
		
		public function get chatEnabled() : Boolean
		{
			return _chatEnabled;
		}
	
		public function getHistory(charId : String) : ArrayList
		{
			return _history[charId];
		}
		
		public function receiveChat(fromLogin : String, fromUserId : Number, message : Object, toLogin : String = null, toUserId : Number = 0) : void
		{
			var notification : Notification = new Notification(fromLogin, fromUserId, message, toLogin, toUserId);
			addToHistory(notification);
			_receiveNotificationEvent.sendEvent(notification);
		}
		
		public function sendNotification(notification : INotification) : void
		{
			if(notification.toLogin != null)
			{
				addToHistory(notification);
				//new MessageService(null, onFault).sendPrivateChat(notification.to, notification.message);
				
				var command:PrivateMessage = new PrivateMessage();
				command.message = notification.message;
				new MessageService().sendCommand(notification.toUserId, command);
			}
			else
			{
				if(Global.locationManager.location){
					//Global.locationManager.location.sendChat(notification.message);
					new MessageService().locationPublicChat(notification.message, Global.locationManager.location.remoteId);
					Global.notifications.receiveChat(notification.fromLogin, notification.fromUserId, notification.message);
				}
			}
		}
		
		private function addToHistory(notification : INotification) : void
		{
			var key : String = (notification.toUserId == Global.charManager.userId)
				? notification.fromLogin
				: notification.toLogin;
			
			if(!_history[key])
				_history[key] = new ArrayList();
				
			var list : ArrayList = _history[key];
			list.addItem(notification);
			
			// add to stack
			_stack.push(notification);
			if (_stack.length > STACK_LENGTH)
				_stack.shift();
		}
		
		private function onSendNotification(notification : Notification) : void
		{
			sendNotification(notification);
		}
	}
}