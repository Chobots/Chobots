package com.kavalok.utils 
{
	import com.gskinner.geom.ColorMatrix;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.interfaces.IRequirement;
	import com.kavalok.utils.comparing.ClassRequirement;
	import com.kavalok.utils.comparing.PropertyCompareRequirement;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class GraphUtils
	{
		public static const CONFIG_ID:String = 'txtModule';

		static public var stage:Stage;
		
		public static function getChildrenRect(container:DisplayObjectContainer):Rectangle
		{
			if(container.numChildren == 0)
				return new Rectangle(0,0,0,0);
			
			var minX : Number = Number.MAX_VALUE;
			var maxX : Number = Number.MIN_VALUE;
			var minY : Number = Number.MAX_VALUE;
			var maxY : Number = Number.MIN_VALUE;
			for(var i : uint = 0; i < container.numChildren; i++)
			{
				var child : DisplayObject = container.getChildAt(i);
				
				// Add null checking for child
				if (child != null) {
					minX = Math.min(minX, child.x);
					minY = Math.min(minY, child.y);
					maxX = Math.max(maxX, child.x + child.width);
					maxY = Math.max(maxY, child.y + child.height);
				}
			}
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		static public function optimizeBackground(content:Sprite):void
		{
			content.opaqueBackground = true;
			content.cacheAsBitmap = true;
			content.mouseEnabled = false;
			content.mouseChildren = false;
		}
		
		static public function optimizeSprite(content:Sprite):void
		{
			content.cacheAsBitmap = true;
			content.mouseEnabled = false;
			content.mouseChildren = false;
		}
		
		public static function getLocationId(enter:Sprite):String
		{
			var text : String = getConfigString(enter);
			var rows:Array = text.split('\r');
			
			return Strings.trim(rows[0]);
		}
		public static function hasParameters(item:Sprite, configId : String = CONFIG_ID):Boolean
		{
			return getConfigString(item, configId) != null;
			
		}
		public static function getParameters(item:Sprite, configId : String = CONFIG_ID):Object
		{
			var text : String = getConfigString(item, configId);
			return textToParameters(text);
		}
		
		public static function textToParameters(text : String):Object
		{
			var rows:Array = text.split('\r');
			var result : Object = {};			
			for (var i:int = 0; i < rows.length; i++)
			{
				var row:String = rows[i];
				var pairs:Array = row.split('=');
				
				if (Strings.trim(row).length > 0)
					result[Strings.trim(pairs[0])] = Strings.trim(pairs[1]); 
			}
			return result;
		}
		
		public static function getConfigString(item:DisplayObjectContainer, configId : String = CONFIG_ID):String
		{
			var textField : TextField = TextField(item.getChildByName(configId));
			if(textField)
			{
				textField.visible = false;
				return Strings.trim(textField.text);
			}
			return null;
		}
		
		static public function roundCoords(item:DisplayObject):void
		{
			item.x = Math.round(item.x);
			item.y = Math.round(item.y);
		}
		
		static public function getPixel(item:DisplayObject, x:int, y:int):int
		{
			var bitmapData:BitmapData = new BitmapData(4, 4);
			var matrix:Matrix = new Matrix();
			matrix.tx = -x;
			matrix.ty = -y;
			
			bitmapData.draw(item, matrix,
				item.transform.colorTransform,
				item.blendMode);
			
			return bitmapData.getPixel(1, 1);
		}
		
		static public function applySepiaEffect(sprite:Sprite):void
		{
			adjustSaturation(sprite, -100);
			var transform:ColorTransform = new ColorTransform(1, 1, 1, 1, 35, 25 , 0);
			sprite.transform.colorTransform = transform;
		}
		
		static public function adjustSaturation(sprite:Sprite, saturation:int = 0):void
		{
			var matrix:ColorMatrix = new ColorMatrix();
			matrix.adjustSaturation(saturation);
			addFilters(sprite, [new ColorMatrixFilter(matrix)]); 
		}
		
		static public function stopAllChildren(clip:Sprite, frameNum:int = -1):void
		{
			var children:Array = getAllChildren(clip, new TypeRequirement(MovieClip));
			
			for each (var child:MovieClip in children)
			{
				if (child.totalFrames > 1)
				{
					if (frameNum > 0)
						child.gotoAndStop(frameNum);
					else
						child.stop();
				}
			}
		}
		
		public static function scale(component : DisplayObject, maxHeight: Number, maxWidth : Number) : Number {
			var scale : Number = Math.min(maxHeight / component.height, maxWidth / component.width);
			component.height *= scale;
			component.width *= scale;
			return scale;
		}

		static public function fitToObject(item:DisplayObject, object:DisplayObject):void
		{
			fitToBounds(item, object.getBounds(item.parent));
		}
		
		static public function fitToBounds(item:DisplayObject, bounds:Rectangle):void
		{
			scale(item, bounds.height, bounds.width);
			var itemBounds:Rectangle = item.getBounds(item.parent);
			item.x += bounds.x + 0.5 * bounds.width - (itemBounds.x + 0.5 * itemBounds.width);
			item.y += bounds.y + 0.5 * bounds.height - (itemBounds.y + 0.5 * itemBounds.height);
		}
		
		public static function claimBounds(object:DisplayObject, bounds:Rectangle):void
		{
			var rect:Rectangle = object.getBounds(object.parent);
			
			if (rect.left < bounds.left)
				object.x += bounds.left - rect.left;
			else if (rect.right > bounds.right)
				object.x += bounds.right - rect.right;
				
			if (rect.top < bounds.top)
				object.y += bounds.top - rect.top;
			else if (rect.bottom > bounds.bottom)
				object.y += bounds.bottom - rect.bottom;
		}
		
		static public function playAllChildren(clip:MovieClip):void
		{
			clip.play();
			
			var children:Array = getAllChildren(clip, new TypeRequirement(MovieClip));
			
			for each (var child:MovieClip in children)
			{
				if (child.totalFrames > 1)
					child.play();
			}
		}
		
		static public function setCoords(content:DisplayObject, coords:Object):void
		{
			content.x = coords.x;
			content.y = coords.y;
		}
		
		static public function attachAfter(sprite:DisplayObject, after:DisplayObject):void
		{
			after.parent.addChildAt(sprite, after.parent.getChildIndex(after) + 1);
		}
		
		static public function attachBefore(sprite:DisplayObject, before:DisplayObject):void
		{
			before.parent.addChildAt(sprite, before.parent.getChildIndex(before));
		}
		
		static public function addFilters(target:DisplayObject, filters:Array):void
		{
			target.filters = target.filters.concat(filters);
		}
		
		static public function removeFilters(target:DisplayObject, filters:Array):void
		{
			var flt:Array = target.filters;
			flt.splice(flt.length - filters.length, filters.length)
			target.filters = flt;
		}
		
		static public function fromRGB(r:uint, g:uint, b:uint):uint
		{
			return r << 16 | g << 8 | b;
		}
		
		static public function toRGB(color:uint):Object
		{
			return { r: color >> 16, g: color >> 8 & 0x0000FF, b: color & 0x0000FF };  
		}
		
		static public function sign(num:Number):int
		{
			if (num > 0)
				return 1;
			else if (num < 0)
				return -1;
			else
				return 0;
		}
		
		public static function setButtonText(button : SimpleButton, text : String = null) : void
		{
			var states : Array = [button.upState, button.downState, button.overState];
			for each(var state : DisplayObject in states)
			{
				if(state is Sprite)
				{
					var textField : TextField = TextField(findInstance(Sprite(state), TextField));
					if(textField != null)
						textField.text = text;
				} else if(state is TextField)
				{
					TextField(state).text = text;
				}
			}
			
		}		
		
		static public function removeAllChildren(
			object:DisplayObjectContainer,
			requirement:IRequirement = null):void
		{
			var children : Array = getAllChildren(object, requirement);
			for each(var child : DisplayObject in children)
			{
				if(child.parent)
					child.parent.removeChild(child);
			}
			
		}
		static public function hideConfigs(object:DisplayObjectContainer, configId : String = CONFIG_ID) : void
		{
			setChildrenVisibility(object, new PropertyCompareRequirement("name", configId), false);		
		}
		
		
		static public function setChildrenVisibility(object:DisplayObjectContainer,
			requirement:IRequirement = null, visible : Boolean = false) : void
		{
			var children : Array = getAllChildren(object, requirement);
			for each(var child : DisplayObject in children)
				child.visible = visible;			
		}
		
		static public function getAllChildren(
			object:DisplayObjectContainer,
			requirement:IRequirement = null, recursive:Boolean = true):Array
		{
			var result:Array = [];
			
			for (var i:int = 0; i < object.numChildren; i++)
			{
				var child:DisplayObject;
				try
				{
					child = object.getChildAt(i);
				}
				catch(e : SecurityError)
				{
					//Ok. can be thrown if child is loaded from another domain
				}
				if (child && (requirement == null || requirement.meet(child)))
					result.push(child)
				
				if (recursive && child is DisplayObjectContainer)
					result = result.concat(getAllChildren(DisplayObjectContainer(child), requirement));
					
			}
			
			return result;
		}
		
		static public function getFirstChild(
			object:DisplayObjectContainer,
			requirement:IRequirement = null):DisplayObject
		{
			var result:Array = getAllChildren(object, requirement);
			
			return (result.length > 0) ? result[0] : null;
		}
		
		static public function createRectSprite(width:Number, height:Number, color:int = 0x000000, alpha:Number = 1):Sprite
		{
			var sprite:Sprite = new Sprite();
			
			sprite.graphics.beginFill(color, alpha);
			sprite.graphics.drawRect(0, 0, width, height);
			sprite.graphics.endFill();
			
			return sprite;
		}
		
		static public function attachModalShadow(content:Sprite, center : Boolean = false):void
		{
			if(center)
			{
				var diffX : Number = (KavalokConstants.SCREEN_WIDTH - content.width) / 2;
				var diffY : Number = (KavalokConstants.SCREEN_HEIGHT - content.height) / 2;
				for(var i : uint = 0; i < content.numChildren; i++)
				{
					var child : DisplayObject = content.getChildAt(i);
					
					// Add null checking for child
					if (child != null) {
						child.x += diffX;
						child.y += diffY;
					}
				}
			}
			
			var shadow:Sprite = createRectSprite(
				KavalokConstants.SCREEN_WIDTH,
				KavalokConstants.SCREEN_HEIGHT,
				KavalokConstants.MODAL_SHADOW_COLOR,
				KavalokConstants.MODAL_SHADOW_ALPHA
			)
			
			content.addChildAt(shadow, 0);
		}
		
		static public function addBoundsRect(object:Sprite, color:int = 0, alpha:Number = 0):Sprite
		{
			var bounds:Rectangle = object.getBounds(object);
			var rect:Sprite = createRectSprite(bounds.width, bounds.height, color, alpha);
			object.addChild(rect);
			rect.x = bounds.x;
			rect.y = bounds.y;
			
			return rect;
		}
		
		public static function transformCoords(point:Point, source:DisplayObject, dest:DisplayObject):Point
		{
			var p:Point = dest.globalToLocal(source.localToGlobal(point));
			
			point.x = p.x;
			point.y = p.y;
			
			return point;
		}
		
		public static function changeParent(item:DisplayObject, newParent:Sprite):void
		{
			var point:Point = GraphUtils.objToPoint(item);
			GraphUtils.transformCoords(point, item.parent, newParent);
			
			item.x = point.x;
			item.y = point.y;
			
			newParent.addChild(item);
		}
		
		public static function setBtnEnabled(object:SimpleButton, enabled:Boolean):void
		{
			object.mouseEnabled = enabled;
			object.enabled = enabled;
			object.alpha = (enabled) ? 1 : 0.3;
		}
		
		public static function makeGray(object:Sprite):void
		{
			var colorMatrix : ColorMatrix = new ColorMatrix();
			colorMatrix.adjustSaturation(-100);
			var filter : ColorMatrixFilter = new ColorMatrixFilter(colorMatrix); 
			object.filters = [filter];
		}
		
		public static function disableMouse(object:Sprite):void
		{
			object.mouseEnabled = false;
			object.mouseChildren = false;
		}
		
		public static function enableMouse(object:Sprite):void
		{
			object.mouseEnabled = true;
			object.mouseChildren = true;
		}
		
		public static function bringToFront(object:DisplayObject):void
		{
			var parent:DisplayObjectContainer = object.parent;
			parent.setChildIndex(object, parent.numChildren - 1);
		}
		
		public static function sendToBack(object:DisplayObject):void
		{
			var parent:DisplayObjectContainer = object.parent;
			parent.setChildIndex(object, 0);
		}
		
		public static function objToPoint(object:DisplayObject):Point
		{
			return new Point(object.x, object.y);
		}
		
		public static function findInstance(container:DisplayObjectContainer, instanceClass:Class):DisplayObject
		{
			var result:DisplayObject = null;
			
			for (var i:int = 0; i < container.numChildren; i++)
			{
				result = container.getChildAt(i);
				
				if (result is instanceClass)
					return result;
				
				if (result is DisplayObjectContainer)
				{
					result = findInstance(DisplayObjectContainer(result), instanceClass);
					if (result != null)
						return result;
				}
			}
			
			return null;
		}
		
		public static function replaceContent(container:DisplayObjectContainer, content:DisplayObject):void
		{
			removeChildren(container);
			container.addChild(content);
		}
		
		public static function removeChildren(parent : DisplayObjectContainer) : void {
			while(parent.numChildren > 0)
			{
				parent.removeChildAt(0);
			}
		}

		public static function distance2(p1:Point, p2:Point):Number
		{
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			
			return dx*dx + dy*dy;
		}
		
		public static function distance(p1:Object, p2:Object):Number
		{
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			
			return Math.sqrt(dx*dx + dy*dy);
		}
		
		public static function claimRange(value:Number, min:Number, max:Number):Number
		{
			if (value < min)
			{
				return min;
			}
			else if (value > max)
			{
				return max;
			}
			else
			{
				return value;
			}
		}
		
		public static function alignCenter(object:DisplayObject, bounds:Rectangle):void
		{
			var rect:Rectangle = object.getBounds(object.parent);
			
			object.x += 0.5 * (bounds.left + bounds.right) - 0.5 * (rect.left + rect.right); 
			object.y += 0.5 * (bounds.top + bounds.bottom) - 0.5 * (rect.top + rect.bottom); 
		}
		
		public static function angleDiff(angle1:Number, angle2:Number):Number
		{
			angle1 %= 2 * Math.PI;
			angle2 %= 2 * Math.PI;
			
			if (angle1 < 0) angle1 += 2 * Math.PI;
			if (angle2 < 0) angle2 += 2 * Math.PI;
			
			var diff:Number = angle2 - angle1;
			
			if (diff < -Math.PI) diff += 2 * Math.PI;
			if (diff > Math.PI) diff -= 2 * Math.PI;
			
			return diff;
		}
		
		public static function framesToTime(numFrames:int):Date
		{
			var t:Number = numFrames / stage.frameRate;
			var seconds:int = int(t);
			var minutes:int = seconds / 60;
			var hours:int = seconds / 3600; 
			var mseconds:int = (t - seconds) * 1000;
			
			return new Date(0, 0, 0, hours, minutes, seconds, mseconds);
		}
		
		public static function simplifyAngle(value:Number):Number
		{
			while (value >= 360)
				value-=360;
			while (value < 0)
				value+=360;
			return value;
		}

		public static function getRandomZonePoint(zone:Sprite, targetCoordinateSpace:Sprite = null):Point
		{
			if (!targetCoordinateSpace)
				targetCoordinateSpace = zone;
			
			var bounds:Rectangle = zone.getBounds(targetCoordinateSpace);
			
			var point:Point = null;
			
			while (!point)
			{
				var pLocal:Point = new Point(
					bounds.left + Math.random() * bounds.width,
					bounds.top + Math.random() * bounds.height);
					
				var pGlobal:Point = targetCoordinateSpace.localToGlobal(pLocal);
					
				if (zone.hitTestPoint(pGlobal.x, pGlobal.y, true))
					point = pLocal;
			}
			return point;
		}
		
		static public function randomItem(array:Array):Object
		{
			return array[int(Math.random() * array.length)];
		}
		
		public static function addChildAtCenter(object:DisplayObject, container:DisplayObjectContainer):void
		{
			var rect1:Rectangle = container.getBounds(container);
			container.addChild(object);
			var rect2:Rectangle = object.getBounds(container);
			
			object.x += 0.5 * (rect1.left + rect1.right - rect2.left - rect2.right);   
			object.y += 0.5 * (rect1.top + rect1.bottom - rect2.top - rect2.bottom);   
		}
		
		public static function detachFromDisplay(displyObject:DisplayObject):void
		{
			if (displyObject != null && displyObject.parent != null)
			{
				displyObject.parent.removeChild(displyObject);
			}
		}
		
		public static function enableDoubleClick(content:DisplayObjectContainer, value:Boolean = true):void
		{
			var children:Array = GraphUtils.getAllChildren(content,
				new ClassRequirement(InteractiveObject));
				
			for each (var child:InteractiveObject in children)
			{
				child.doubleClickEnabled = value;
			}
		}
		
		static public function getFilters(spriteClass:Class):Array
		{
			var sprite:Sprite = new spriteClass(); 
			return Sprite(sprite.getChildAt(0)).filters;
		}
		
		static public function extractTextFieldsFromButton(button:SimpleButton):Array
		{
			var result:Array = [];
			
			var states:Array = [button.upState, button.downState, button.overState];
			for each(var state:DisplayObject in states)
			{
				if (state is TextField)
				{
					result.push(state);
				}
				else if (state is DisplayObjectContainer)
				{
					var textField:TextField = TextField(findInstance(
						DisplayObjectContainer(state), TextField));
					if(textField != null)
						result.push(textField);
				}
			}
			return result;
		}
		
		static public function convertToBitmap(source:DisplayObject, rect:Rectangle):Bitmap
		{
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height);
			bitmapData.draw(source);
			var bitmap:Bitmap = new Bitmap(bitmapData);
			return bitmap;
		}
	}
}