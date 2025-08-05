package org.goverla.localization {
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.goverla.events.EventSender;
	import org.goverla.interfaces.ICommand;

	public class LoadMessagesAction implements ICommand {
		
		private var _url : String;
		private var _bundle : ResourceBundle;
		private var _loader : URLLoader;
		
	
		private var _loaded:EventSender = new EventSender();
		private var _failed:EventSender = new EventSender();
		private var _status:String;
		private var _locale:String;

		public function LoadMessagesAction(url : String, bundle : ResourceBundle)
		{
			_url = url;
			_bundle = bundle;
			_locale = bundle.locale;
		}
		
		public function get loaded():EventSender
		{
			return _loaded;
		}

		public function get failed():EventSender
		{
			return _failed;
		}
		
		public function execute():void
		{
			_loader = new URLLoader(new URLRequest(_url));
			_loader.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
		}
		
		private function onLoadComplete(event : Event) : void
		{
			if(_locale != _bundle.locale)
				return; //locale has changed while loading
				
			var xml : XML = new XML(_loader.data);
			for each(var child : XML in xml.children())
			{
				var text : String = String(child.text());
				if(_bundle.textConverter)
					text = String(_bundle.textConverter.convert(text));
				_bundle.messages[child.name()] = text;
			}
			_loaded.sendEvent();
		}
		
		private function onHttpStatus(event : HTTPStatusEvent) : void
		{
			_status = event.toString();
		}
		private function onIOError(event : IOErrorEvent) : void
		{
			trace(event.text + " " + _status);
			_failed.sendEvent();
			//throw new Error("Error loading localization from " + _url);
		}
		
	}
}