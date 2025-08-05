package com.kavalok.loaders
{
	import com.kavalok.Global;
	import com.kavalok.events.EventSender;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class SafeURLLoader extends URLLoader
	{
		private var _completeEvent:EventSender = new EventSender();
		private var _errorEvent:EventSender = new EventSender();
		private var _url:String;
		private var _tryCount:int = 5;
		private var _view:ILoaderView;
		
		public function SafeURLLoader(view:ILoaderView = null)
		{
			_view = view;
			
			addEventListener(Event.COMPLETE, onLoadComplete);
			addEventListener(IOErrorEvent.IO_ERROR, onLoadFault);
			
			if (_view)
				addEventListener(ProgressEvent.PROGRESS, onProgress);
		}
		
		override public function load(request:URLRequest):void
		{
			super.load(new URLRequest(SafeLoader.rootUrl + request.url));
		}
		
		private function onLoadComplete(e:Event):void
		{
			_completeEvent.sendEvent();
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			_view.percent = e.bytesLoaded / e.bytesTotal * 100;
		}
		
		private function onLoadFault(e:IOErrorEvent):void
		{
			if (--_tryCount > 0)
			{
				load(new URLRequest(_url));
			}
			else
			{
				_errorEvent.sendEvent();
				trace('File not found: ' + _url);
			}
		}
		
		public function get completeEvent():EventSender
		{
			return _completeEvent;
		}
		
		public function get errorEvent():EventSender
		{
			return _errorEvent;
		}
	}
}