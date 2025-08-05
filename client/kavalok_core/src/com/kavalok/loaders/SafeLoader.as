package com.kavalok.loaders
{
	import com.kavalok.Global;
	
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class SafeLoader extends ViewLoader
	{
		public static var rootUrl : String = "";
		
		private var _tryCount:int = 5;
		private var _url:String;
		
		public function SafeLoader(view:ILoaderView = null)
		{
			super(view);
		}
		
		override public function load(request:URLRequest, context:LoaderContext=null):void
		{
			super.load(new URLRequest(rootUrl + request.url), context);
		}
		
		override protected function onLoadFault(e:IOErrorEvent):void
		{
			if (--_tryCount > 0)
			{
				load(new URLRequest(_url));
			}
			else
			{
				super.onLoadFault(e);
			}
		}
		
	}
}