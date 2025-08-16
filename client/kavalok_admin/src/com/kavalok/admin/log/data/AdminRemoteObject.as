package com.kavalok.admin.log.data
{
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.remoting.RemoteObject;
	import com.kavalok.utils.Strings;
	
	import org.goverla.events.EventSender;

	public class AdminRemoteObject extends RemoteObject
	{
		
		private static const USER_SENT_ADMIN_MESSAGE : String = " on server <b>{0}</b> has sent admin message : <b>{1}</b>";
		private static const USER_ENTER : String = " enter to server <b>{0}</b> <b>{1}</b>";
		private static const FIRST_LOGIN : String = "FIRST LOGIN!!!";
		
		private var _resourceBundle : ResourceBundle;

		private var _messageEvent:EventSender = new EventSender();
		private var _badWordEvent:EventSender = new EventSender();
		private var _charMessageEvent:EventSender = new EventSender();
		private var _reportEvent:EventSender = new EventSender();
		
		public function AdminRemoteObject()
		{
			super("admin_shared_object");
			
			_resourceBundle = Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
		}
		
		public function get charMessageEvent():EventSender { return _charMessageEvent; }
		public function get messageEvent():EventSender { return _messageEvent; }
		public function get badWordEvent():EventSender { return _badWordEvent; }
		public function get reportEvent():EventSender { return _reportEvent; }
		
		public function onUserReport(charId : String, userId : int, message : String, id : int) : void
		{
			reportEvent.sendEvent(new UserReport(charId, userId, message, id));
		}
//		public function onUserMessage(charId : String, message : String) : void
//		{
//			charMessageEvent.sendEvent(new UserMessage(charId, message));
//		}
		
		public function onMessage(message : String) : void
		{
			messageEvent.sendEvent(message);
		}
//		public function onAdminMessage(charId : String, server : String, message : String) : void
//		{
//			message = StringUtil.substitute(USER_SENT_ADMIN_MESSAGE, _resourceBundle.messages[server], message);
//			charMessageEvent.sendEvent(new UserMessage(charId, message));
//		}
		public function onBadWord(charId : String, userId : int, server : String, word : String, message : String, type : String) : void
		{
			badWordEvent.sendEvent(new BadMessage(charId, userId, Strings.removeHTML(message), word, type));
		}
//		public function onEnterGame(charId : String, server : String, firstLogin : Boolean) : void
//		{
//			var firstLoginText : String = firstLogin ? FIRST_LOGIN : "";
//			var message : String = StringUtil.substitute(USER_ENTER, _resourceBundle.messages[server], firstLoginText)
//			charMessageEvent.sendEvent(new UserMessage(charId, message));
//		}
	}
}