package com.kavalok.gameplay.notifications
{
	import com.kavalok.Global;
	import com.kavalok.dialogs.Dialogs;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.utils.Strings;
	
	import flash.net.registerClassAlias;
	
	public class Notification implements INotification
	{
		public static function initialize() : void
		{
			registerClassAlias("com.kavalok.gameplay.notifications.Notification", Notification);
		}
		
		private var _icon : Class;
		private var _message : Object;
		private var _fromLogin : String;
		private var _toLogin : String;
		private var _fromUserId : Number;
		private var _toUserId : Number;
		
		public function Notification(fromLogin : String = null, fromUserId : Number = -1, message : Object = null, toLogin : String = null, toUserId : Number = -1)
		{
			_fromLogin = fromLogin;
			_fromUserId = fromUserId;
			_message = (message is String) ? checkMessage(String(message)) : message;
			_toLogin = toLogin;
			_toUserId = toUserId;
		}
		
		private function checkMessage(message:String):String
		{
			// check word length
			var words:Array = message.split(' ');
			for each (var word:String in words)
			{
				if (word.length > KavalokConstants.MAX_CHAT_WORD)
					message = message.replace(word, '');
			}
			
			return Strings.removeHTML(message);
		}

		public function set icon(value : Class):void
		{
			_icon = value;
		}
		public function get icon():Class
		{
			return null;
		}
		
		public function getText():String
		{
			var result:String = '';
			if(message is String)
			{
				result = message as String;
			}
			else
			{
				for each(var word:String in message)
				{
					result += Global.resourceBundles.safeChat.messages[word] + " ";
				}
			}
			return result;
		}
		
//		public function set fromLogin(value:String) : void
//		{
//			_fromLogin = value;
//		}
		public function get fromLogin():String
		{
			return _fromLogin;
		}
		
		public function set fromUserId(value:Number) : void
		{
			_fromUserId = value;
		}

		public function get fromUserId():Number
		{
			return _fromUserId;
		}

		public function set toLogin(value:String) : void
		{
			_toLogin = value;
		}
		public function get toLogin():String
		{
			return _toLogin;
		}
		
		public function set toUserId(value:Number) : void
		{
			_toUserId = value;
		}

		public function get toUserId():Number
		{
			return _toUserId;
		}
		
		public function set message(value:Object) : void
		{
			_message = value;
		}
		public function get message():Object
		
		{
			return _message;
		}
		
	}
}