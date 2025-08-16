package com.kavalok.admin.magic
{
	import com.kavalok.Global;
	import com.kavalok.location.commands.FlyingPromoCommand;
	import com.kavalok.location.commands.PlaySwfCommand;
	import com.kavalok.utils.Strings;
	import com.kavalok.loaders.SafeURLLoader;
	import flash.events.Event;
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
		
		private function loadList():void
		{
			var loader:SafeURLLoader = new SafeURLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest('resources/magic/magic.xml'));
		}
		
		private function onLoadComplete(e:Event):void 
		{
			var list:ArrayList = new ArrayList();
			var xml:XML = new XML(SafeURLLoader(e.target).data);
			for each (var item:String in xml.item) 
			{
				list.addItem(item);
			}
			animationList = list;
		}
		
		protected function refreshByCombo():void 
		{
			// Use the full URL path with the base prefix, but extract just the path portion
			var fullUrl:String = Global.urlPrefix + URL_PREFIX + urlCombo.selectedItem;
			
			// Extract just the path portion (remove protocol, hostname, port)
			var urlPath:String = fullUrl;
			if (fullUrl.indexOf("://") != -1) {
				// Remove protocol and hostname/port
				urlPath = fullUrl.substring(fullUrl.indexOf("/", fullUrl.indexOf("://") + 3));
			}
			
			animationURL = urlPath;
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