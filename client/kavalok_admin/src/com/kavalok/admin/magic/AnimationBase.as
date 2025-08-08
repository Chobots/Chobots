package com.kavalok.admin.magic
{
	import com.kavalok.location.commands.FlyingPromoCommand;
	import com.kavalok.location.commands.PlaySwfCommand;
	import com.kavalok.utils.Strings;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import org.goverla.collections.ArrayList;
	
	/**
	 * ...
	 * @author Canab
	 */
	public class AnimationBase extends MagicViewBase
	{
		static public const URL_PREFIX:String = 'resources/magic/';
		
		[Bindable] public var urlField:TextInput;
		[Bindable] public var urlCombo:ComboBox;
		[Bindable] public var animationURL:String;
		[Bindable] public var promoInput:TextInput;
		
		[Bindable] public var animationList:ArrayList;
		
		public function AnimationBase()
		{
			super();
			if (this.stage)
				onAddedToStage();
			else
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			loadList();
		}
		
		private function getResourceUrl(path:String):String
		{
			var swfUrl:String = loaderInfo.url.split('?')[0];
			return swfUrl.substr(0, swfUrl.lastIndexOf('/') + 1) + path;
		}
		
		private function loadList():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest(getResourceUrl('resources/magic/magic.xml')));
		}
		
		private function onLoadComplete(e:Event):void 
		{
			var list:ArrayList = new ArrayList();
			var xml:XML = new XML(URLLoader(e.target).data);
			for each (var item:String in xml.item) 
			{
				list.addItem(item);
			}
			animationList = list;
		}
		
		protected function refreshByCombo():void 
		{
			animationURL = getResourceUrl(URL_PREFIX + urlCombo.selectedItem);
			urlField.text = animationURL;
		}
		
		protected function refreshByInput():void 
		{
			animationURL = Strings.trim(urlField.text);
			urlCombo.selectedItem = null;
		}
		
		public function onSendClick():void
		{
			var command:PlaySwfCommand = new PlaySwfCommand();
			command.url = animationURL;
			sendLocationCommand(command);
		}
		
		public function sendPromoText():void 
		{
			var text:String = Strings.trim(promoInput.text);
			
			if (!Strings.isBlank(text))
			{
				var command:FlyingPromoCommand = new FlyingPromoCommand();
				command.text = text;
				sendLocationCommand(command);
			}
		}
	}
	
}