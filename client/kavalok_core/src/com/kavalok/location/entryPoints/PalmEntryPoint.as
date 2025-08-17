package com.kavalok.location.entryPoints
{
	import com.kavalok.Global;
	import com.kavalok.char.CharModels;
	import com.kavalok.char.Directions;
	import com.kavalok.char.LocationChar;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.MousePointer;
	import com.kavalok.gameplay.constants.Competitions;
	import com.kavalok.location.LocationBase;
	import com.kavalok.location.entryPoints.palm.BallMovement;
	import com.kavalok.location.entryPoints.palm.Point3D;
	import com.kavalok.services.CompetitionService;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.Maths;
	import com.kavalok.utils.ReflectUtil;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.Timers;
	import com.kavalok.utils.comparing.ClassRequirement;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class PalmEntryPoint extends EntryPointBase
	{
		public static const GRAV_ACC : Number = -0.1;
		public static const TARGET_Z : Number = 117;
		private static const MONEY : Number = 1;
		private static const SPEED_XY : Number = 6;
		private static const START_Z : Number = 20;
		private static const TARGET_SPEED : Point = new Point(3,7);
		private static const TARGET_SIZE : uint = 65;
		private static const MISS_DIST : uint = 9;
		private static const PREFIX : String = "palmBall_";
		private static const PALM_NAME_PREFIX : String = "palm_";
		private static const PALM_NAME : String = "palm";
		private static const PALM_TYPE_PREFIX : String = "Palm";
		private static const TOOL_CLASS_PREFIX : String = "PalmBall";
		private static const TOOL_FILE_PREFIX : String = "palmBall";
		private static const ANIMATION_TIME : uint = 2000;
		
		private var _arrow : MovingPowerArrow;
		private var _currentBall : String;
		private var _targetSpeed : Point;
		private var _palms : Array = [];
		private var _currentPalm : MovieClip;
		private var _currentTarget : MovieClip;
		private var _horTargetPoint : MovieClip;
		private var _vertTarget : MovieClip;
		private var _horTargetBall : MovieClip;
		private var _vertTargetBall : MovieClip;
		private var _clickCount : uint = 0;
		
		private var _horizontalCoords : Point;
		private var _verticalCoords : Point;
		
		public function PalmEntryPoint(location : LocationBase)
		{
			PalmBlue; PalmBallBlue;
			PalmGreen, PalmBallGreen;
			PalmRed; PalmBallRed,
			PalmSnow; PalmBallSnow;
			
			_location = location;
			registerPalms(_location.content);
			registerPalms(_location.charContainer);
			super(location, PREFIX, location.remoteId);
		}
		
		private function get color() : String
		{
			return getColor(_currentBall);
		}

		private function getColor(ballId :String) : String
		{
			return ballId.split("_")[1];
		}
		
		public function get palms() : Array
		{
			return _palms;
		}
		
		public function removeBall(ball:MovieClip):void
		{
			_location.content.removeChild(ball);
		}

		override public function initialize(mc:MovieClip):void
		{
			super.initialize(mc);
			MousePointer.registerObject(mc, MousePointer.ACTION);
		}
		
		override public function restoreState(state:Object):void
		{
			super.restoreState(state);
			for each(var palm : MovieClip in _palms)
			{
				addLeaf(palm);
			}
		}
		
		override public function goIn():void
		{
			super.goIn();
			if(_currentBall != null)
				removeState("rUnlockBall", _currentBall);
				
			lockState("rLockBall", clickedClip.name);
		}
		
		public function sendRedrawPalm(color : String, palmName : String, owner : String) : void
		{
			if(owner == clientCharId)
			{
				sendState("rRedrawPalm", palmName, {color : color});
			}
		}
		public function rRedrawPalm(stateId : String, state : Object) : void
		{
			var type : Class = ReflectUtil.getTypeByName(PALM_TYPE_PREFIX + state.color);
			var leaf : MovieClip = new type();
			leaf.mouseEnabled = false;
			leaf.mouseChildren = false;
			leaf.gotoAndPlay(2);
			var palm : MovieClip = getPalm(stateId);
			palm.leafs.addChild(leaf);
			leaf.cacheAsBitmap = true;
			leaf.mouseChildren = false;
			leaf.mouseEnabled = false;
			Timers.callAfter(removeLeaf, ANIMATION_TIME, this, [palm.leafs, getPalmLeaf(palm)]);
		}
		
		public function removeLeaf(leafs : DisplayObjectContainer, leaf : DisplayObject) : void
		{
			if(leaf.parent == leafs)
			{
				leafs.removeChild(leaf);
			}
		}
		
		public function rLockBall(ballId : String, state : Object) : void
		{
			Timers.callAfter(hideBall, 400, this, [getBall(ballId)]);
			if(state.owner == clientCharId)
			{
				Global.frame.tips.addTip("takeBall");
				_currentBall = ballId;
				var tool:String = TOOL_FILE_PREFIX + getColor(ballId);
				Global.charManager.tool = tool;
				_location.sendUserModel(CharModels.TAKE, -1, tool);
				for each(var palm : MovieClip in _palms)
				{
					palm.target.horizontal.visible = false;
					palm.addEventListener(MouseEvent.MOUSE_DOWN, onPalmMouseDown);
					palm.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					palm.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
					palm.activeNimb.gotoAndPlay(1);
					
					if(palm.hitTestPoint(palm.stage.mouseX, palm.stage.mouseY, true))
					{
						setCurrentPalm(palm);
					}
				}
				_location.content.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private function getPalmLeaf(palm : MovieClip) : MovieClip
		{
			return MovieClip(palm.leafs.getChildAt(0));
		}

		private function getPalm(id : String) : MovieClip
		{
			return _location.content[id] || _location.charContainer[id];
		}


		private function registerPalms(container : Sprite) : void
		{
			for(var i : uint = 0; i < container.numChildren; i++)
			{
				var child : DisplayObject = container.getChildAt(i);
				if(child is MovieClip && (Strings.startsWidth(child.name, PALM_NAME_PREFIX) || child.name == PALM_NAME))
				{
					_palms.push(child);
					MovieClip(child).background.alpha = 0; 
					MovieClip(child).target.visible = false; 
					MovieClip(child).target.target.visible = false;
					MovieClip(child).activeNimb.gotoAndStop(1);
				}
			}
		}
		private function hideBall(ball : MovieClip) : void
		{
			ball.visible = false;
		}
		
		private function getBall(ballId : String) : MovieClip
		{
			return _location.charContainer[ballId];	
		}
		
		private function addLeaf(palm : MovieClip) : void
		{
			if(palm == null)
				return;
			GraphUtils.removeChildren(palm.leafs);
			var color : String = states[palm.name] == null ? "Blue" : states[palm.name].color;
			var type : Class = ReflectUtil.getTypeByName(PALM_TYPE_PREFIX + color);
			var clip : MovieClip = new type();
			clip.gotoAndStop(clip.totalFrames);
			palm.leafs.addChild(clip);
			clip.cacheAsBitmap = true;
		}
		
		private function onMouseOut(event : MouseEvent) : void
		{
			if(_currentPalm!=null && !_currentPalm.hitTestPoint(event.stageX, event.stageY, true) 
				&& !_currentTarget.hitTestPoint(event.stageX, event.stageY, true))
				refreshPalm();
		}
		
		private function setCurrentPalm(palm : MovieClip) : void
		{
			GraphUtils.removeAllChildren(Global.root, new ClassRequirement(PalmTargetNew));

			_currentPalm = palm;
			_clickCount = 0;

			_currentTarget = new PalmTargetNew();
			_horTargetPoint = new PalmTargetPoint();
			_vertTarget = new PalmTargetPoint();
			_horTargetBall = new PalmTargetBall();
			_vertTargetBall = new PalmTargetBall();

			_horTargetPoint.y = _currentTarget.y+36;
			_horTargetPoint.x = _currentTarget.x+Math.floor(Math.random() * 60)+10;

			_vertTarget.y = _currentTarget.y+Math.floor(Math.random() * 60)+10;
			_vertTarget.x = _currentTarget.x+36;
			
			_horTargetBall.y = _currentTarget.y+37;
			_horTargetBall.x = _currentTarget.x+5;

			_vertTargetBall.y = _currentTarget.y+5;
			_vertTargetBall.x = _currentTarget.x+37;
			
			_vertTarget.visible = false;
			_vertTargetBall.visible = false;

			
			_currentTarget.addChild(_horTargetPoint);
			_currentTarget.addChild(_vertTarget);
			
			_currentTarget.addChild(_horTargetBall);
			_currentTarget.addChild(_vertTargetBall);

			_horizontalCoords = new Point(_horTargetBall.x, _horTargetBall.y)
			_verticalCoords = new Point(_vertTargetBall.x, _vertTargetBall.y)


			_targetSpeed = new Point(Math.floor(Math.random() * 7)+1, Math.floor(Math.random() * 7)+1);

			var point : Point = GraphUtils.transformCoords(new Point(0,0), _currentPalm, Global.root);
			_currentTarget.x = point.x-30;
			_currentTarget.y = point.y-150;

			_currentTarget.x = Maths.normalizeValue(_currentTarget.x, 0, KavalokConstants.SCREEN_WIDTH - _currentTarget.width);
			_currentTarget.y = Maths.normalizeValue(_currentTarget.y, 0, KavalokConstants.SCREEN_HEIGHT - _currentTarget.height);

			Global.root.addChild(_currentTarget);
			_currentTarget.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_currentTarget.addEventListener(MouseEvent.MOUSE_DOWN, onPalmMouseDown);
		}
		private function refreshPalm() : void
		{
			_currentPalm.target.visible = false;
			GraphUtils.removeAllChildren(Global.root, new ClassRequirement(PalmTargetNew));
			_currentTarget = null;
			_currentPalm = null;
			 
		}
		
		private function onMouseOver(event : MouseEvent) : void
		{
			setCurrentPalm(MovieClip(event.currentTarget));
		}
		
		private function onEnterFrame(event : Event) : void
		{
			if(_currentPalm == null)
				return;

			_horTargetBall.x += _targetSpeed.x;	
			_vertTargetBall.y += _targetSpeed.y;	
			
			if(_vertTargetBall.y > TARGET_SIZE + _verticalCoords.y)
			{
				_targetSpeed.y *=-1;
				_vertTargetBall.y = 2*(TARGET_SIZE + _verticalCoords.y)- _vertTargetBall.y;
			}
			if(_horTargetBall.x > TARGET_SIZE + _horizontalCoords.x)
			{
				_targetSpeed.x *=-1;
				_horTargetBall.x = 2*(TARGET_SIZE + _horizontalCoords.x)- _horTargetBall.x;
			}
			if(_vertTargetBall.y < _verticalCoords.y)
			{
				_targetSpeed.y *=-1;
				_vertTargetBall.y = 2*_verticalCoords.y - _vertTargetBall.y;
			}
			if(_horTargetBall.x < _horizontalCoords.x)
			{
				_targetSpeed.x *=-1;
				_horTargetBall.x = 2*_horizontalCoords.x - _horTargetBall.x;
			}
		}
		private function onPalmMouseDown(event : MouseEvent) : void
		{
			
			_targetSpeed.x = 0;
			if(_clickCount==0){
				_vertTarget.visible = true;
				_vertTargetBall.visible = true;
				_clickCount = 1;
			}else{
				_targetSpeed.y = 0;
				var success : Boolean = Math.abs(_horTargetPoint.x - _horTargetBall.x) < MISS_DIST
				 && Math.abs(_vertTarget.y - _vertTargetBall.y) < MISS_DIST;
				shoot(success);
				for each(var palm : MovieClip in _palms)
				{
					palm.activeNimb.gotoAndStop(1);
				}
				refreshPalm();
			}
		}
		
		private function shoot(sucess : Boolean) : void
		{
			_location.sendUserTool(null);
			for each(var palm : MovieClip in _palms)
			{
				MousePointer.unRegisterObject(palm);
				palm.target.visible = false;
				palm.removeEventListener(MouseEvent.MOUSE_DOWN, onPalmMouseDown);
				palm.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				palm.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
			_location.content.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			removeState("rUnlockBall", _currentBall);
			var userPosition : Point = _location.user.position;
			var distY : Number = _currentPalm.y - userPosition.y;
			var distX : Number = _currentPalm.x - userPosition.x;
			var distXY : Number = Math.sqrt(distY*distY + distX*distX);
			var t : Number = distXY / SPEED_XY;
			
			var z : Number = sucess ? TARGET_Z : 1.5 * TARGET_Z + Math.random()*TARGET_Z;
			
			var powerZ : Number = (z - GRAV_ACC * t * t / 2) / t; 
			var angleY : Number = Math.atan2(_currentPalm.y - userPosition.y, _currentPalm.x - userPosition.x); 
			var powerX : Number = Math.cos(angleY) * SPEED_XY;
			var powerY : Number = Math.sin(angleY) * SPEED_XY;
			_location.user.position = userPosition;
			send("rShoot", clientCharId, _currentPalm.name, color, userPosition.x, userPosition.y, powerX, powerY, powerZ);
		}
		
		public function rShoot(charId : String, palmId : String, color : String, xPos : Number, yPos : Number, powerX : Number, powerY : Number, powerZ : Number) : void
		{
			var char:LocationChar = _location.chars[charId];
			if(char != null)
			{
				char.position = new Point(xPos, yPos);
				//char.tool = "";
				var palm : MovieClip = getPalm(palmId);
				char.setModel(CharModels.THROW, Directions.getDirection(palm.x - xPos, palm.y - yPos));
				var type : Class = ReflectUtil.getTypeByName(TOOL_CLASS_PREFIX + color);
				var ball : MovieClip = new type();
				_location.content.addChild(ball);
				ball.x = xPos;
				ball.y = yPos;
				var resultHandler : Function = charId == clientCharId ? onPalmResult : null;
				new BallMovement(color, this, getPalm(palmId), ball, new Point3D(powerX, powerY, powerZ), charId, resultHandler);
			}
		}
		
		
		private function onPalmResult(success : Boolean) : void
		{
			_location.sendAddBonus(success ? MONEY : 0, Competitions.PALM);
			if(success)
				new CompetitionService().addResult(Competitions.PALM, MONEY);
		}
		public function rUnlockBall(ballId : String) : void
		{
			getBall(ballId).visible = true;
		}
		
	}
}