package com.kavalok.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.system.ApplicationDomain;
	
	public class SpriteDecorator
	{
		static public const PART_PREFIX:String = '_Ch';
		static private const ASSET_PREFIX:String = 'Mc';
		static private const COLOR:String = 'mcColor';
		static private const BORDER:String = 'mcBorder';
		static private const DEFAULT_PERCENT:int = 50;
		
		static public function decorateModel(sprite:Sprite, items:Array, cleanFlag:Boolean = false, recursive:Boolean = false):void
		{
			var parts:Array = GraphUtils.getAllChildren(
				sprite, new NameRequirement(PART_PREFIX, true), recursive);
				
			var oneHandProcessed:Boolean;
			var domain:ApplicationDomain;
			var color:int;
			
			for each (var item:Object in items)
			{
				domain = item.domain;
				color = item.color;
				oneHandProcessed = false;
				
				for each (var part:Sprite in parts)
				{
					if (!domain)
						continue;
					
					var assetName:String = ASSET_PREFIX + part.name.substr(PART_PREFIX.length);
					assetName = assetName.split("_")[0];
					
					while (cleanFlag && part.numChildren > 0)
					{
						part.removeChildAt(0);
					}
					
					if (!domain.hasDefinition(assetName))
						continue;
					
					var assetClass:Class = Class(domain.getDefinition(assetName));
					var asset:Sprite = new assetClass();
					
					if (asset.hasOwnProperty('oneHand'))
					{
						if (!oneHandProcessed)
						{					
							oneHandProcessed = true;
							continue;
						}
					}
					
					if (color >= 0)
						decorateColor(asset, color);
					
					part.addChild(asset);
				}
				
				cleanFlag = false;
			}
		}
		
		static public function decorateColor(asset:Sprite, color:int):void
		{
			var colorInfo:Object = GraphUtils.toRGB(color);
			var children:Array = GraphUtils.getAllChildren(asset);
			
			for each (var child:DisplayObject in children)
			{
				if (child is Sprite)
				{
					var transform:ColorTransform = null;
					
					if (child.name == COLOR)
					{
						transform = new ColorTransform(
							colorInfo.r/255.0, colorInfo.g/255.0, colorInfo.b/255.0, child.alpha);
					}
					else if (child.name.indexOf(BORDER) == 0)
					{
						var percent:int = parseInt(child.name.substr(BORDER.length));
						if (percent == 0)
							percent = DEFAULT_PERCENT;
						 
						var k:Number = percent / 100.0;
						
						transform = new ColorTransform(0, 0, 0, 1,
							colorInfo.r * k, colorInfo.g * k, colorInfo.b * k, child.alpha);
					}
					
					if (transform)
						child.transform.colorTransform = transform;
				}
			}
		}
		
	}
}