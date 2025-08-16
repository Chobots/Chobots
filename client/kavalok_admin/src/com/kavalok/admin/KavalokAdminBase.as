package com.kavalok.admin
{
	import com.kavalok.Global;
	import com.kavalok.dto.StateInfoTO;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.loaders.SafeLoader;
	import com.kavalok.gameplay.KavalokConstants;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import flash.events.Event;
	

	public class KavalokAdminBase extends Application
	{
		initialize();
		private static function initialize() : void
		{
			StateInfoTO.initialize();
		}
		
		public function KavalokAdminBase()
		{
			super();
			
			// Wait for the stage to be available before setting up localization
			if (this.stage)
				initializeLocalization();
			else
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
			addEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);
		}
		
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initializeLocalization();
		}
		
		private function initializeLocalization():void
		{
			// Set up the URL prefix based on the SWF's location
			var swfURL:String = loaderInfo.url.split('?')[0];
			Global.urlPrefix = swfURL.substr(0, swfURL.lastIndexOf('/') + 1);
			
			// Initialize the SafeLoader to use the correct root URL
			SafeLoader.rootUrl = Global.urlPrefix;
			
			// Set up localization URL format with the correct prefix
			Localiztion.urlFormat = Global.urlPrefix + KavalokConstants.LOCALIZATION_URL_FORMAT;
			
			// Set default locale for admin
			Localiztion.locale = "enUS";
		}
		
		private function onPreinitialize(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
			
			// Update URL prefix if loaderInfo is now available and different
			if (loaderInfo && loaderInfo.url)
			{
				var swfURL:String = loaderInfo.url.split('?')[0];
				var newUrlPrefix:String = swfURL.substr(0, swfURL.lastIndexOf('/') + 1);
				
				if (newUrlPrefix != Global.urlPrefix)
				{
					Global.urlPrefix = newUrlPrefix;
					SafeLoader.rootUrl = Global.urlPrefix;
					Localiztion.urlFormat = Global.urlPrefix + KavalokConstants.LOCALIZATION_URL_FORMAT;
				}
			}
		}
		
		private function onApplicationComplete(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.APPLICATION_COMPLETE, onApplicationComplete);
		}
		
	}
}