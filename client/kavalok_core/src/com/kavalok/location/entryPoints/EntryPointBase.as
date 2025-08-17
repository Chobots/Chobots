package com.kavalok.location.entryPoints
{
	import com.kavalok.events.EventSender;
	import com.kavalok.location.LocationBase;
	import com.kavalok.remoting.ClientBase;
	import com.kavalok.utils.Strings;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class EntryPointBase extends ClientBase implements IEntryPoint
	{
		protected var clickedClip : MovieClip;
		
		private var _prefix : String;
		private var _content : DisplayObjectContainer;
		private var _acivateEvent : EventSender = new EventSender();
		private var _hasPoints:Boolean = false;
		protected var _location:LocationBase;
		
		public function EntryPointBase(location : LocationBase, prefix : String, remoteId : String = null)
		{
			_location = location;
			_content = location.content;
			_prefix = prefix;
			
			processContent(_content);
			if(location.charContainer)
				processContent(location.charContainer);
			
			if (_hasPoints && remoteId)
				connect(remoteId);
		}
		
		public function get charPosition():Point 
		{
			return new Point(clickedClip.x, clickedClip.y);
		}
		
		public function get activateEvent():EventSender
		{
			return _acivateEvent;
		}

		public function initialize(mc:MovieClip):void{}
		public function destroy():void
		{
			if(connected)
				disconnect();
		}
		
		public function accept(mc:MovieClip):Boolean
		{
			return Strings.startsWidth(mc.name, _prefix);
		}
		
		public function goIn() : void {}
		public function goOut() : void {}		
		
		private function processContent(content : DisplayObjectContainer) : void
		{
			for(var i : int = 0; i < content.numChildren; i++)
			{
				// Add bounds checking for AMF3 compatibility
				if (i >= content.numChildren) break;
				
				var child : MovieClip = content.getChildAt(i) as MovieClip;
				if(child != null && accept(child))
				{
					initialize(child);
					child.addEventListener(MouseEvent.CLICK, onClick);
					_hasPoints = true;
				}
			}
		}
		
		protected function onClick(event : MouseEvent) : void
		{
			clickedClip = MovieClip(event.currentTarget);
			activateEvent.sendEvent(this);
		}
		
		public function get hasPoints():Boolean
		{
			 return _hasPoints;
		}
		
	}
}