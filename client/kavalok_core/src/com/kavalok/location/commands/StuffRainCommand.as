package com.kavalok.location.commands
{
	import com.kavalok.Global;
	import com.kavalok.dto.stuff.StuffTypeTO;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.ResourceSprite;
	import com.kavalok.gameplay.commands.RetriveStuffByIdCommand;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.Maths;
	import com.kavalok.utils.SpriteTweaner;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class StuffRainCommand extends RemoteLocationCommand
	{
		public var itemId:int;
		public var fileName:String;
		public var stuffType:String
		
		private var _stuff:ResourceSprite;
		private var _speed:int = 5;
		
		public function StuffRainCommand()
		{
		}
		
		public function onReady(sender:ResourceSprite):void
		{
			var w:int = KavalokConstants.SCREEN_WIDTH;
			var h:int = KavalokConstants.SCREEN_HEIGHT;
			
			_stuff.y = -_stuff.height;
			_stuff.x = 0.1 * w + 0.8 * Math.random() * w;
			_stuff.readyEvent.removeListener(onReady);
			_stuff.content.x = -0.5 * _stuff.content.width;
			_stuff.content.y = -0.5 * _stuff.content.height;
			_stuff.buttonMode = true;
			_stuff.addEventListener(MouseEvent.CLICK, onClick);
			_stuff.addEventListener(Event.ENTER_FRAME, moveDown);
			
			GraphUtils.addBoundsRect(_stuff);
			Global.locationContainer.addChild(_stuff);
		}
		
		private function moveDown(e:Event):void
		{
			_stuff.y += _speed;
			if (_stuff.y > KavalokConstants.SCREEN_HEIGHT + _stuff.height)
				onDown();
		}
		
		private function onClick(e:MouseEvent):void
		{
			_stuff.removeEventListener(Event.ENTER_FRAME, moveDown);
			_stuff.mouseEnabled = false;
			
			new SpriteTweaner(_stuff, {scaleX: 0, scaleY: 0}, 10, null, onDown);
			new RetriveStuffByIdCommand(itemId, 'chobots', Maths.random(0xffffff)).execute();
		}
		
		private function onDown(e:Object = null):void
		{
			GraphUtils.detachFromDisplay(_stuff);
		}
		
		override public function execute():void
		{
			var info:StuffTypeTO = new StuffTypeTO();
			info.fileName = fileName;
			info.id = itemId;
			info.type = stuffType;
			
			_stuff = info.createModel();
			_stuff.readyEvent.addListener(onReady);
			_stuff.loadContent();
		}
		
	}
}