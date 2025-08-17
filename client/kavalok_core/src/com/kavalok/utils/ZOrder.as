package com.kavalok.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ZOrder
	{
		private var _content:Sprite;
		
		public function ZOrder(content:Sprite)
		{
			_content = content;
			
			_content.addEventListener(Event.ADDED_TO_STAGE, startMonitoring);
			_content.addEventListener(Event.REMOVED_FROM_STAGE, stopMonitoring);
			
			if (_content.stage)
				startMonitoring();
		}
		
		private function startMonitoring(e:Event = null):void
		{
			_content.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function stopMonitoring(e:Event = null):void
		{
			_content.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (_content.numChildren == 0)
				return;
			
			// Add bounds checking for AMF3 compatibility
			if (_content.numChildren <= 0) return;
			
			var prevChild:DisplayObject = _content.getChildAt(0);
			
			for (var i:int = 1; i < _content.numChildren; i++)
			{
				// Add bounds checking before accessing child
				if (i >= _content.numChildren) break;
				
				var currentChild:DisplayObject = _content.getChildAt(i);
				
				if (currentChild.y < prevChild.y)
				{
					var j:int = i - 1;
					
					while (j >= 0 && j < _content.numChildren && currentChild.y < _content.getChildAt(j).y)
					{
						j--;
					}
					
					// Ensure the new index is valid
					var newIndex:int = Math.max(0, Math.min(j + 1, _content.numChildren - 1));
					_content.setChildIndex(currentChild, newIndex);
				}
				else
				{
					prevChild = currentChild;
				}
			}
			
		}
		
	}
}