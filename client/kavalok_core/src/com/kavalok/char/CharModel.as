package com.kavalok.char
{
	import com.kavalok.Global;
	import com.kavalok.URLHelper;
	import com.kavalok.constants.StuffTypes;
	import com.kavalok.dto.stuff.StuffItemLightTO;
	import com.kavalok.events.EventSender;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.SpriteDecorator;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	public class CharModel extends Sprite
	{
		public var cacheEnabled:Boolean = true;
		public var factory : IModelsFactory = new DefaultModelsFactory();
		public var head:Sprite;
		
		private var _readyEvent:EventSender = new EventSender();
		
		private var _char:Char;
		
		private var _content:MovieClip;
		private var _modelName:String = CharModels.STAY;
		private var _direction:int = Directions.DOWN;
		
		private var _assets:Array = [];
		private var _assetsLoaded:Boolean;
		private var _modelCache:Object = {};
		private var _assetsAnimation : Boolean = false;
		private var _modelAnimation : Boolean = true;
		private var _headScale:Number = 1;
		
		public function CharModel(char:Char = null)
		{
			_char = char || new Char();
		}
		
		public function set char(value:Char):void
		{
			 _char = value;
			 _assetsLoaded = false;
			 _modelCache = [];
			 
			 refresh();
		}
		
		public function setModel(modelName:String, direction:int = -1):void
		{
			_modelName = modelName;
			
			if (direction >= 0)
				_direction = direction;
				
			refresh();
		}
		
		public function get assetsAnimation():Boolean
		{
			 return _assetsAnimation;
		}
		
		public function set assetsAnimation(value:Boolean):void
		{
			 if (value != _assetsAnimation)
			 {
			 	_assetsAnimation = value;
			 	if (_content && !_assetsAnimation)
			 		GraphUtils.stopAllChildren(_content, 1);
			 }
		}
		
		public function refresh():void
		{
			if (_assetsLoaded)
				createModel();
			else
				loadAssets();
		}
		
		public function reload():void
		{
			_modelCache = [];
			_assetsLoaded = false;
			refresh();
		}
		
		private function loadAssets():void
		{
			var urlList:Array = [URLHelper.charBodyURL(_char.body)];
			
			if (_char.tool)
				urlList.push(URLHelper.charToolURL(_char.tool));
			
			for each (var info:StuffItemLightTO in _char.clothes)
			{
				urlList.push(URLHelper.stuffURL(info.fileName, StuffTypes.CLOTHES));
			}
			
			Global.classLibrary.callbackOnReady(onAssetsComplete, urlList);
		}
		
		private function onAssetsComplete():void
		{
			_assets = [];
			var bodyDomain:ApplicationDomain = Global.classLibrary.getDomain(URLHelper.charBodyURL(_char.body));
			if (!bodyDomain)
				return;
			_assets.push({domain: bodyDomain, color: _char.color});
			
			if (_char.tool)
			{
				var toolDomain:ApplicationDomain = Global.classLibrary.getDomain(URLHelper.charToolURL(_char.tool));
				if (!toolDomain)
					return;
				_assets.push({domain: toolDomain, color: -1});
			}
			
			_char.clothes.sort(sortOnPlacement);
			
			for each(var info:StuffItemLightTO in _char.clothes)
			{
				var url:String = URLHelper.stuffURL(info.fileName, StuffTypes.CLOTHES);
				var domain:ApplicationDomain = Global.classLibrary.getDomain(url);
				if (!domain)
					return;
				_assets.push({domain: domain, color: info.color});
			}
			
			createModel();
			
			_assetsLoaded = true;
			_readyEvent.sendEvent();
		}
		
		private function sortOnPlacement(item1:StuffItemLightTO, item2:StuffItemLightTO):Number
		{
			const ORDER:String = 'XHFMLBN*';
			var num1:int = ORDER.indexOf(item1.placement.charAt(0));
			var num2:int = ORDER.indexOf(item2.placement.charAt(0));
			
			if (num1 == num2)
				return 0;
			else if (num1 > num2)
				return -1;
			else
				return 1;
		}
		
		private function createModel():void
		{
			destroy();
			
			var key:String = '' + _char.tool + _modelName + _direction;
			
			if (key in _modelCache)
			{
				_content = _modelCache[key];
				_content.gotoAndPlay(1);
			}
			else
			{
				_content = factory.getModel(_char.tool != null, _modelName, _direction);
				_content.mouseEnabled = false;
				_content.mouseChildren = false;
				
				var board:Sprite = new Sprite();
				board.name = '_ChBoard';
				_content.addChildAt(board, 0);
				
				decorateModel();
				
				if (cacheEnabled)
				{
					if (_modelName.indexOf(CharModels.WALK) == 0)
						_modelCache[key] = _content;
				}
			}
			
			_content.addEventListener(Event.CHANGE, onChangeInAnim);
			
			if (!_modelAnimation)
				_content.stop();
			
			updateHead();
			addChild(_content);
		}
		
		public function set headScale(value:Number):void
		{
			 _headScale = value;
			 if (_content)
			 	updateHead();
		}
		
		public function set modelAnimation(value:Boolean):void
		{
			 _modelAnimation = value;
		}
		
		public function get modelAnimation():Boolean
		{
			 return _modelAnimation;
		}
		
		private function updateHead():void
		{
			var part:Sprite;
			var i:int;
			
			for (i = 0; i < _content.numChildren; i++)
			{
				// Add bounds checking for AMF3 compatibility
				if (i >= _content.numChildren) break;
				
				part = _content.getChildAt(i) as Sprite;
				if (part && part.name.indexOf('_ChHead') == 0)
				{
					head = part;
					break;
				}
			}
			
			// Add null check for head before accessing its children
			if (head != null) {
				for (i = 0; i < head.numChildren; i++)
				{
					// Add bounds checking for AMF3 compatibility
					if (i >= head.numChildren) break;
					
					part = head.getChildAt(i) as Sprite;
					if (part) // can be null !!!
						part.scaleX = part.scaleY = _headScale;
				}
			}
		}
		
		private function onChangeInAnim(e:Event = null):void
		{
			decorateModel();
			updateHead();
		}
		
		private function decorateModel():void
		{
			SpriteDecorator.decorateModel(_content, _assets, true);
			
			if (!_assetsAnimation || !_modelAnimation)
				GraphUtils.stopAllChildren(_content);
				
			var bottom:Number = _content.getBounds(_content).bottom; 
			if (bottom > 5)
				_content.y = -bottom + 5
			else
				_content.y = 0;
		}
		
		public function rotateLeft():void
		{
			var direction:int = (_direction == 7) ? 0 : _direction + 1;
			setModel(_modelName, direction); 
		}
		
		public function rotateRight():void
		{
			var direction:int = (_direction == 0) ? 7 : _direction - 1;
			setModel(_modelName, direction); 
		}
		
		public function destroy():void
		{
			if (_content)
			{
				if (contains(_content))
					removeChild(_content);
					
				_content.removeEventListener(Event.CHANGE, onChangeInAnim);
				_content.gotoAndStop(_content.totalFrames);
				_content = null;
			}
		}
		
		public function set scale(value:Number):void
		{
			 scaleX = scaleY = value;
		}
		
		public function set position(value:Object):void
		{
			 x = value.x;
			 y = value.y;
		}
		
		public function get readyEvent():EventSender { return _readyEvent; }
		
		public function get char():Char { return _char; }
		public function get content():MovieClip { return _content; }
		public function get isReady():Boolean { return _assetsLoaded; }
		public function get modelName():String { return _modelName; }
		public function get direction():int { return _direction; }
	}
}
