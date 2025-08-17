package com.kavalok.gameplay
{
	import com.kavalok.gameplay.controls.FlashViewBase;
	import com.kavalok.utils.ReflectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public class FlashView extends FlashViewBase
	{
		public const MAP_PREFIX:String = 'mc_';
		
		public function FlashView(content:Sprite) 
		{
			super(content);
			if (content == null) 
			{
				throw new Error('Content of View cannot be null.');
			}
			
			mapObjects(content);
			
		}
		
		public function detachContent():void
		{
			if (content.parent != null) 
			{
				content.parent.removeChild(content);
			}
		}
		
		private function mapObjects(container:DisplayObjectContainer):void
		{
			for (var i:int = 0; i < container.numChildren; i++)
			{
				// Add bounds checking for AMF3 compatibility
				if (i >= container.numChildren) break;
				
				var d:DisplayObject = container.getChildAt(i);
				
				if (d.name.indexOf(MAP_PREFIX) != 0) 
				{
					continue;
				}
				
				var propName:String = d.name.substr(3);
				
				if (propName in this) 
				{
					this[propName] = d;
				}
				
				if (d is DisplayObjectContainer) 
				{
					mapObjects(DisplayObjectContainer(d));
				}
			}
		}
		
		protected function handle(handler:Function):void
		{
			if (handler != null) 
			{
				handler();
			}
		}
		
	}
}
