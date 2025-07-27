package com.kavalok.location
{
	import com.kavalok.Global;
	import com.kavalok.char.Bonus;
	import com.kavalok.char.Char;
	import com.kavalok.char.CharModels;
	import com.kavalok.char.CharStates;
	import com.kavalok.char.Directions;
	import com.kavalok.char.IIdleFactory;
	import com.kavalok.char.IModelsFactory;
	import com.kavalok.char.LocationChar;
	import com.kavalok.char.Stuffs;
	import com.kavalok.char.actions.CharActionBase;
	import com.kavalok.constants.ClientIds;
	import com.kavalok.dto.pet.PetTO;
	import com.kavalok.events.EventSender;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.LocationBot;
	import com.kavalok.gameplay.MousePointer;
	import com.kavalok.gameplay.Music;
	import com.kavalok.gameplay.PathBuilder;
	import com.kavalok.gameplay.ToolTips;
	import com.kavalok.gameplay.chat.BubbleStyle;
	import com.kavalok.gameplay.chat.BubbleStyles;
	import com.kavalok.gameplay.infoPanel.InfoPanel;
	import com.kavalok.gameplay.notifications.Notification;
	import com.kavalok.gameplay.windows.ShowCharViewCommand;
	import com.kavalok.interfaces.IRequirement;
	import com.kavalok.location.commands.RemoteLocationCommand;
	import com.kavalok.location.entryPoints.ChairEntryPoint;
	import com.kavalok.location.entryPoints.ChobotStatueEntry;
	import com.kavalok.location.entryPoints.GameEntryPoint;
	import com.kavalok.location.entryPoints.IEntryPoint;
	import com.kavalok.location.entryPoints.LocationEntryPoint;
	import com.kavalok.location.entryPoints.PalmEntryPoint;
	import com.kavalok.location.entryPoints.RobotCombatEntry;
	import com.kavalok.location.entryPoints.TableGame;
	import com.kavalok.location.entryPoints.TeamEntryPoint;
	import com.kavalok.location.modifiers.AnalogClockModifier;
	import com.kavalok.location.modifiers.CompetitionModifier;
	import com.kavalok.location.modifiers.DigitalClockModifier;
	import com.kavalok.location.modifiers.DoorsModifier;
	import com.kavalok.location.modifiers.FactoryModifier;
	import com.kavalok.location.modifiers.IClipModifier;
	import com.kavalok.location.modifiers.LocationModifierBase;
	import com.kavalok.location.modifiers.PalmModifier;
	import com.kavalok.location.randomClips.LinkClip;
	import com.kavalok.location.randomClips.MouseActiveClip;
	import com.kavalok.location.randomClips.MouseActiveClip2;
	import com.kavalok.location.randomClips.RandomMovieClip;
	import com.kavalok.pets.PetManager;
	import com.kavalok.pets.PetWindowView;
	import com.kavalok.remoting.ClientBase;
	import com.kavalok.remoting.RemoteCommand;
	import com.kavalok.remoting.RemoteObjects;
	import com.kavalok.services.LocationService;
	import com.kavalok.services.MoneyService;
	import com.kavalok.utils.Arrays;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.TypeRequirement;
	import com.kavalok.utils.ZOrder;
	import com.kavalok.utils.comparing.PropertyCompareRequirement;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import gs.TweenLite;
	import gs.easing.Expo;
	
	public class LocationBase extends ClientBase
	{
		static public const STATE_POSITION:String = 'P|';
		
		static public const Z_SPRITE_NAME:String = 'mc_zOrderSprite';
		static public const DEFAULT_POS_NAME:String = 'mc_defCharPos';
		
		static private const GRID_STEP:uint = 9;
		static private const IDLE_TIME:int = 50; //seconds
		static private const POS_DELTA:int = 40;
		
		static private const MIN_NUM_CHARS_SCALE:Number = 15;
		static private const MAX_NUM_CHARS_SCALE:Number = 180;
		static private const MIN_CHARS_SCALE:Number = 0.6;
		static private const MAX_CHARS_SCALE:Number = 1.1;
		static private const MIN_ANIM_CHARS_SCALE:Number = 0.65; 
		static private const NUM_CHARS_FOR_HIDE_NAMES:Number = 70;
		
		protected var shadowEnabled:Boolean = true;
		protected var _charModelsFactory:IModelsFactory;
		
		private var _readyEvent:EventSender = new EventSender();
		private var _destroyEvent:EventSender = new EventSender();
		private var _userAdded:EventSender = new EventSender();
		private var _userPosChanged:EventSender = new EventSender();
		private var _charAddedEvent:EventSender = new EventSender(LocationChar);
		
		private var _locId:String;
		private var _newLocId:String;
		private var _user:LocationChar;
		private var _chars:Object = {};
		
 		private var _clipModifiers:Array = [];
 		private var _locationModifiers:Object = {};
 		
		private var _pathBuilder:PathBuilder;
		private var _entryPoints:Array = [];
		private var _currentPoint:IEntryPoint;
 		private var _activePoint:IEntryPoint;
		
		private var _charsScale:Number = 1;
		private var _initialCoords:Point;
		private var _predefinedCharsScale:Number = Number.MIN_VALUE;
		private var _userIdleTimer:Timer;
		private var _petIdleTimer:Timer;
		
		private var _content:Sprite;
		private var _ground:Sprite;
		private var _charContainer:Sprite;
		private var _bot:LocationBot;
		private var _showCharNames:Boolean;
		private var _children:Array;
		private var _initioaPositions:Array = [];
		
		public function LocationBase(locId:String, remoteId:String = null)
		{
			super();
			
			_remoteId = (remoteId == null) ? locId : remoteId
			_locId = locId;
			
			addModifier(new FactoryModifier(RandomMovieClip.RANDOM_CLIP_PREFIX, RandomMovieClip));
			addModifier(new FactoryModifier(MouseActiveClip.VARIABLE_CLIP_PREFIX, MouseActiveClip));
			addModifier(new FactoryModifier(MouseActiveClip2.MOUSE_ACTIVE2_PREFIX, MouseActiveClip2));
			addModifier(new FactoryModifier(LinkClip.PREFIX, LinkClip));
			addModifier(new FactoryModifier(TableGame.CLIP_NAME, TableGame, this));
			addModifier(new FactoryModifier(RobotCombatEntry.CLIP_NAME, RobotCombatEntry, this));
			addModifier(new FactoryModifier(CompetitionModifier.PREFIX, CompetitionModifier));
			addModifier(new FactoryModifier(AnalogClockModifier.PREFIX, AnalogClockModifier));
			addModifier(new FactoryModifier(DigitalClockModifier.PREFIX, DigitalClockModifier));
			addModifier(new FactoryModifier(InfoPanel.PREFIX, InfoPanel));
			addModifier(new FactoryModifier(ChobotStatueEntry.CLIP_NAME, ChobotStatueEntry, this));
			addModifier(new DoorsModifier());
			addModifier(new PalmModifier());
			
		}
		
		private function updateCharScale():void
		{
			 var numChars:int = remote.connectedChars.length;
			 var koef:Number = (GraphUtils.claimRange(numChars, MIN_NUM_CHARS_SCALE, MAX_NUM_CHARS_SCALE) - MIN_NUM_CHARS_SCALE) / 
			 	(MAX_NUM_CHARS_SCALE - MIN_NUM_CHARS_SCALE);
			 
			 var newScale:Number = MAX_CHARS_SCALE - koef * (MAX_CHARS_SCALE - MIN_CHARS_SCALE);
			 
			 if (Math.abs(newScale - _charsScale) > 0.04)
			 	setCharsScale(newScale);
			 	
			 if (_showCharNames && numChars > NUM_CHARS_FOR_HIDE_NAMES)
			 	showCharNames = false;
			
			 if (Global.showCharNames && !_showCharNames && numChars <= NUM_CHARS_FOR_HIDE_NAMES)
			 	showCharNames = true;
		}
		
		private function setCharsScale(value:Number):void
		{
			 trace('numChars:', remote.connectedChars.length, 'scale:', value);
			
			_charsScale = value;
			
			for each (var char:LocationChar in _chars)
			{
				char.scaleMult = _charsScale;
				char.modelAnimation = (_charsScale > MIN_ANIM_CHARS_SCALE);

				if (char.pet)
				{
					char.pet.scale = _charsScale;
					char.pet.animationEnabled = char.modelAnimation;
				} 
			}
		}
		
		public function set predefinedCharsScale(value:Number):void
		{
			_predefinedCharsScale = value;
			
			if (_predefinedCharsScale != Number.MIN_VALUE)
				setCharsScale(_predefinedCharsScale);
			else
				updateCharScale();
		}
		
		public function get invitationParams():Object
		{
			return {email : Global.charManager.email
				, userId : clientUserId
				, charId : clientCharId
				, remoteId : Global.locationManager.remoteId};			
		}
		
		public function setContent(value:Sprite):void
		{
			_content = value;
			_children = GraphUtils.getAllChildren(_content);
		}
		
		protected function optimize():void
		{
			var bitmapData:BitmapData = new BitmapData(
				KavalokConstants.SCREEN_WIDTH, KavalokConstants.SCREEN_HEIGHT);
			var matrix:Matrix = new Matrix();
			matrix.translate(background.x, background.y);
			bitmapData.draw(background, matrix);
			var bitmap:Bitmap = new Bitmap(bitmapData);
			bitmap.cacheAsBitmap = true;
			bitmap.smoothing = true;
			
			GraphUtils.removeChildren(background);
			background.addChild(bitmap);
			background.x = 0;
			background.y = 0;
			GraphUtils.optimizeBackground(background);			
			
			_children = GraphUtils.getAllChildren(_content);
			
			var items:Array = Arrays.getByRequirement(_children,
				new PropertyCompareRequirement('name', 'idle'));
				
			for each (var item:Sprite in items)
			{
				trace('optimize:', item.name);
				GraphUtils.optimizeSprite(item);
			}
		}
		
		protected function addModifier(modifier : IClipModifier):void
		{
			_clipModifiers.push(modifier);
		}
		
		override public function get id():String
		{
			return ClientIds.LOCATION;
		}
		
		////////////////////////////////////////////////
		// init
		////////////////////////////////////////////////
		
		public function create():void
		{
			_ground = _content['ground'];
			_ground.alpha = 0;
			
			_pathBuilder = new PathBuilder(_ground, GRID_STEP);
			_charContainer = Sprite(_content.getChildByName(Z_SPRITE_NAME));
			
			if (!_charContainer)
			{
				_charContainer = new Sprite();
				_content.addChild(_charContainer);
			}
			
			new ZOrder(_charContainer);
			MousePointer.registerObject(_ground, MousePointer.WALK);
			Global.music.play(musicList);
			
			initPoints();
			initStartPoint();
			if (!initialCoords)
				throw new Error('It is impossible to determine user position!');
			
			addPoint(new GameEntryPoint(this));
			addPoint(new TeamEntryPoint(this));
			addPoint(new ChairEntryPoint(this));
			addPoint(new PalmEntryPoint(this));
			
			modifyChildren();
			optimize();
			initPositions();
			connect(_remoteId);
		}
		
		private function initPositions():void
		{
			for (var i:int = 0; i < _children.length; i++)
			{
				var child:DisplayObject = _children[i];
				_initioaPositions[i] = new Point(child.x, child.y);	
			}
		}
		
		protected function get musicList():Array
		{
			if (locId == 'locPark')
				return ['chrs2'];
			else
				return Music.LOCATION;
		}

		public function refresh():void
		{
			showCharNames = Global.showCharNames;
		}
		
		public function get showCharNames():Boolean
		{
			 return _showCharNames;
		}
		
		public function set showCharNames(value:Boolean):void
		{
			 if (_showCharNames != value)
			 {
			 	_showCharNames = value;
				for each(var locChar : LocationChar in _chars)
				{
					locChar.showName = _showCharNames;
				}
			 }
		}
		
		public override function restoreState(states:Object):void
		{
			super.restoreState(states);
			for (var stateId:String in states)
			{
				var state:Object = states[stateId];
				if (isModifierState(stateId))
					rAddLocationModifier(stateId, state);
				else if (isPositionState(stateId))
					rObjectPosition(stateId, state);
			}
			
			var numChars:int = remote.connectedChars.length;
			if (numChars < 15 && Global.performanceManager.quality == 0)
				Global.performanceManager.quality = 1;
			if (numChars > 100 && Global.performanceManager.quality != 0)
				Global.performanceManager.quality = 0;
			
			addUserChar();
			Global.notifications.receiveNotificationEvent.addListener(onReceiveNotification);
		}
		
		////////////////////////////////////////////////
		// add user
		////////////////////////////////////////////////
		
		protected function addUserChar() : void
		{
			var state:Object = {};
			state[CharStates.USER_ID] = Global.charManager.userId;
			state[CharStates.BODY] = Global.charManager.body;
			state[CharStates.COLOR] = Global.charManager.color;
			state[CharStates.CLOTHES] = Global.charManager.stuffs.getUsedClothesOptimized();
			state[CharStates.MODEL] = CharModels.STAY;
			state[CharStates.DIRECTION] = Directions.DOWN;
			state[CharStates.TOOL] = Global.charManager.tool;
			state[CharStates.X] = initialCoords.x; 
			state[CharStates.Y] = initialCoords.y; 
			state[CharStates.MOOD] = Global.charManager.moodId; 
			state[CharStates.MODIFIERS] = Global.charManager.modifiersList;
			state[CharStates.BUBBLE_STYLE] = Global.charManager.bubleStyle;
			
			var pet:PetTO = Global.petManager.pet;
			if (pet)
			{
				var userAtHome:Boolean = Global.locationManager.isOwnHome;
				if (pet.atHome && userAtHome || !pet.atHome)
				{
					state[CharStates.PET] = pet.getOptimized();
				}
			}
			
			sendUserState('rAddChar', state);
		}
		
		public function rAddChar(stateId:String, state:Object):void
		{
			if(state[CharStates.BODY] == null) //quickfix of clones
			{
				trace('corrupted location state!!!');
				return;
			}
			
			var locChar:LocationChar = createChar(stateId, state);
				
			if (locChar.isUser)
			{
				_user = locChar;
				_user.moveCompleteEvent.addListener(onUserMoveComplete);
				
				_ground.addEventListener(MouseEvent.CLICK, onGroundClick);
				
				if (Global.startupInfo.isBot)
					_bot = new LocationBot(this);
				
				if (locChar.modelsFactory is IIdleFactory && !_bot)
				{
					_userIdleTimer = new Timer(1000 * IDLE_TIME);
					_userIdleTimer.addEventListener(TimerEvent.TIMER, onIdleTimer);
					_userIdleTimer.start();
				}
				
				userAdded.sendEvent(user);
				restoreCharStates();
				sendReady();
			}
		}
		
		private function restoreCharStates():void
		{
			for (var stateId:String in states)
			{
				if (isCharState(stateId) && extractCharId(stateId) != Global.charManager.charId)
					createChar(stateId, states[stateId]);
			}
		}
		
		private function createChar(stateId:String, state:Object):LocationChar
		{
			var charId:String = extractCharId(stateId);
			var position:Point = new Point(state[CharStates.X], state[CharStates.Y]);
			
			var char:Char = new Char();
			char.id = charId;
			char.userId = state[CharStates.USER_ID];
			char.body = state[CharStates.BODY];
			char.color = state[CharStates.COLOR];
			char.clothes = Stuffs.getClothesFromOptimized(state[CharStates.CLOTHES]);
			char.tool = state[CharStates.TOOL];
			
			var locChar:LocationChar = new LocationChar(char);
			if (_charModelsFactory)
				locChar.modelsFactory = _charModelsFactory;
			locChar.position = position;
			locChar.shadowEnabled = Global.performanceManager.shadowEnabled && shadowEnabled;
			locChar.clickEvent.addListener(onCharClick);
			locChar.moodId = state[CharStates.MOOD];
			locChar.bubbleStyleName = state[CharStates.BUBBLE_STYLE];
			locChar.showName = _showCharNames;
			locChar.setModel(CharModels.STAY, state[CharStates.DIRECTION]); 
			_charContainer.addChild(locChar.content);
			_chars[charId] = locChar;
			
			
			if (_predefinedCharsScale == Number.MIN_VALUE)
				updateCharScale();
			
			locChar.scaleMult = _charsScale;

			if("locCitizen"==_locId)
				setCharsScale(1.5);

			locChar.modelAnimation = (_charsScale > MIN_ANIM_CHARS_SCALE);
			
			var modifiers:Array = state[CharStates.MODIFIERS];
			for each (var modifierInfo:Object in modifiers)
			{
				locChar.addModifier(modifierInfo);
			}
			
			if(!Global.showCharNames)
				ToolTips.registerObject(locChar.boundSprite, charId);
				
			if (state[CharStates.PET])
			{
				var petTO:PetTO = new PetTO();
				petTO.setOptimized(state[CharStates.PET]);
				var locPet:LocationPet = createPet(petTO);
				locPet.position =  getPetPosition(locChar.position);
				locPet.scale = _charsScale;
				locChar.pet = locPet;
				_charContainer.addChild(locPet.content);
			}
			_charAddedEvent.sendEvent(locChar);
			return locChar;
		}
		
		protected function sendReady() : void
		{
			readyEvent.sendEvent();
		}
		
		public function sendCustomDance(dance : Array):void
		{
			send("rCustomDance", clientCharId, dance);
		}
		
		public function rCustomDance(charId : String, dance : Array):void
		{
			var char : LocationChar = _chars[charId];
			if(char.danceEnabled)
				char.customDance(dance);
		}
		
		////////////////////////////////////////////////
		// move user
		////////////////////////////////////////////////
		
		public function sendMoveUser(x:int, y:int):void
		{
			Global.charManager.removeStaticModifiers();
			
			var state:Object = {}
			state[CharStates.X] = x;
			state[CharStates.Y] = y;
			state[CharStates.DIRECTION] = Directions.getDirection(x - user.position.x, y - user.position.y);
			
			var petBusy:Boolean = Global.petManager.isBusy;
			
			if (Global.petManager.pet)
				state[CharStates.PET_BUSY] = petBusy;

			moveChar(user, new Point(x, y), petBusy);
			sendUserState('M', state);
			//new LocationService().moveTO(Global.locationManager.location.remoteId, x, y, petBusy);
		}
		
		public function M(stateId:String, state:Object):void
		{
			if (_bot)
				return;
				
			var charId : String = extractCharId(stateId);
			var locChar:LocationChar = _chars[charId];
			
			if (locChar && (charId != clientCharId))
			{
				var petBusy:Boolean = Boolean(state[CharStates.PET_BUSY]);
				var position:Point = new Point(state[CharStates.X], state[CharStates.Y]) 
				moveChar(locChar, position, petBusy);
			}
		}

		public function moveCharServiceCall(charId : String, x : int, y : int, petBusy : Boolean, timeStamp : int):void
		{
			var locChar:LocationChar = _chars[charId];
			if(locChar != null)
				moveChar(locChar, new Point(x, y), petBusy);
		}
		
		private function moveChar(locChar:LocationChar, position:Point, petBusy:Boolean):void
		{
			var path:Array = _pathBuilder.getPath(locChar.position, position);
			if(path)
			{
				locChar.moveByPath(path);
				if (locChar.pet && !petBusy)
					movePet(locChar, getPetPosition(position));
			}
		}
		
		public function movePet(locChar:LocationChar, position:Point):void
		{
			var pet:LocationPet = locChar.pet;
			
			var path:Array = _pathBuilder.getPath(pet.position, position);
			if (!path)
				path = [pet.position, position];
				
			pet.moveByPath(path);
		}
		
		////////////////////////////////////////////////
		// chat
		////////////////////////////////////////////////
		
		public function sendChat(message : Object):void
		{
			send("C", clientCharId, clientUserId, message);
		}
		public function C(from : String, fromUserId : Number, message : Object):void
		{
			Global.notifications.receiveChat(from, fromUserId, message);
		}
		
		////////////////////////////////////////////////
		// pets
		////////////////////////////////////////////////
		
		private function createPet(state:PetTO):LocationPet
		{
			var locPet:LocationPet = new LocationPet(state);
			ToolTips.registerObject(locPet.boundSprite, locPet.pet.name);
			
			if (Global.petManager.isMy(state))
			{
				locPet.clickEvent.addListener(onPetClick);
				Global.petManager.refreshEvent.addListener(onPetRefresh);
				Global.petManager.isBusy = false;
				_petIdleTimer = new Timer(1000 * PetManager.IDLE_PERIOD);
				_petIdleTimer.addEventListener(TimerEvent.TIMER, onPetIdle);
				_petIdleTimer.start();
			}
			
			return locPet;
		}
		
		private function onPetIdle(e:TimerEvent):void
		{
			if (remote.connectedChars.length < 25)
				Global.petManager.doIdleAction();
		}
		
		private function onPetRefresh():void
		{
			if (!Global.petManager.pet)
				sendRemovePet();
		}
		
		private function sendRemovePet():void
		{
			var state:Object = getCharState(clientCharId);
			delete state[CharStates.PET];
			sendUserState('rRemovePet', state);
			_petIdleTimer.stop();
		}
		
		public function rRemovePet(stateId:String, state:Object):void
		{
			var char:LocationChar = _chars[extractCharId(stateId)];
			if (char && char.pet)
			{
				var pet:LocationPet = char.pet;
				char.pet = null;
				removePet(pet);
			}
		}
		
		private function onPetClick(locPet:LocationPet):void
		{
			var window:PetWindowView = Global.windowManager.getPetWindow(locPet.id);
			
			if(window)
				Global.windowManager.activateWindow(window);
			else
				Global.windowManager.showWindow(new PetWindowView(locPet.pet));
		}
		
		private function removePet(pet:LocationPet):void
		{
			pet.destroy();
			GraphUtils.detachFromDisplay(pet.content)
		}
		
		public function getPetPosition(charPosition:Point):Point
		{
			var distance:Number = 20 + Math.random() * 20;
			var angle:Number = Math.random() * 2 * Math.PI; 
			
			var result:Point = new Point();
			result.x = charPosition.x + distance * Math.cos(angle); 
			result.y = charPosition.y + distance * Math.sin(angle); 
			
			return result;
		}
		
		////////////////////////////////////////////////
		// state functions
		////////////////////////////////////////////////
		
		public function sendUserPos(position:Point):void
		{
			var state:Object = {};
			state[CharStates.X] = position.x;
			state[CharStates.Y] = position.y;
			sendUserState('rSetCharPos', state);
		}
		
		public function rSetCharPos(stateId:String, state:Object):void
		{
			var locChar:LocationChar = chars[extractCharId(stateId)];
			if (locChar)
			{
				locChar.position = new Point(state[CharStates.X], state[CharStates.Y]);
				locChar.setModel(CharModels.STAY);
			}
		}
		
		public function sendUserModel(modelName:String, direction:int = -1, tool : String = null):void
		{
			var state:Object = {};
			state[CharStates.MODEL] = modelName;
			state[CharStates.DIRECTION] = direction;
			
			if (tool)
				state[CharStates.TOOL] = tool;
			
			sendUserState('rSetCharModel',  state);
			
			if (_userIdleTimer.running)
			{
				_userIdleTimer.reset();
				_userIdleTimer.start();
			}
		}
		
		public function rSetCharModel(stateId:String, state:Object):void
		{
			if (Global.startupInfo.isBot)
				return;
			
			var locChar:LocationChar = chars[extractCharId(stateId)];
			if (locChar)
			{
				if (state[CharStates.TOOL])
					locChar.char.tool = state[CharStates.TOOL];
				
				locChar.refreshModel();
				locChar.setModel(state[CharStates.MODEL], state[CharStates.DIRECTION]);
			}
		}
		
		public function sendUserTool(tool:String):void
		{
			Global.charManager.tool = tool;
			var state:Object = {};
			state[CharStates.TOOL] = tool;
			sendUserState('rSetCharTool', state);
		}
		
		public function rSetCharTool(stateId:String, state:Object):void
		{
			var locChar:LocationChar = chars[extractCharId(stateId)];
			if (locChar)
			{
				locChar.char.tool = state[CharStates.TOOL]; 
				locChar.refreshModel();
			}
		}
		
		public function sendUpdateClothes():void
		{
			var newState:Object = {};
			newState[CharStates.CLOTHES] = Global.charManager.stuffs.getUsedClothesOptimized(); 
			newState[CharStates.BODY] = Global.charManager.body,
			newState[CharStates.COLOR] = Global.charManager.color, 
			newState[CharStates.TOOL] = Global.charManager.tool
							
			sendUserState('rUpdateClothes',  newState);
		}
		
		public function rUpdateClothes(stateId:String, state:Object):void
		{
			var locChar:LocationChar = _chars[extractCharId(stateId)];
			
			locChar.char.body = state[CharStates.BODY];
			locChar.char.color = state[CharStates.COLOR];
			locChar.char.clothes = Stuffs.getClothesFromOptimized(state[CharStates.CLOTHES]);
			locChar.char.tool = state[CharStates.TOOL];
			
			locChar.refreshModel();
		}
		
		public function sendShowUser() : void
		{
			user.visible = true;
			var state:Object = {};
			state[CharStates.VISIBLE] = true;
			sendUserState("rSetCharVisible", state)
		}
		
		public function sendHideUser() : void
		{
			user.visible = false;
			var state:Object = {};
			state[CharStates.VISIBLE] = true;
			sendUserState("rSetCharVisible", state);
		}
		
		public function rSetCharVisible(stateName : String, state : Object) : void
		{
			var charId : String = extractCharId(stateName);
			var locChar:LocationChar = _chars[charId];
			if (locChar)
				locChar.visible = state[CharStates.VISIBLE];
		}
		
		////////////////////////////////////////////////
		// bonus
		////////////////////////////////////////////////

		public function sendAddBonus(value : uint, reason : String):void
		{
			if(value > 0)
			{
				if(Global.charManager.isCitizen)
					value *= KavalokConstants.CITIZEN_MONEY_MULTIPLIER;

				if (!Global.charManager.isGuest)
					new MoneyService().addMoney(value, reason);
			}
			
			send('rAddBonus', clientCharId, value);
		}

		public function rAddBonus(charId:String, value:int):void
		{
			var locChar:LocationChar = chars[charId];
			if (locChar)
			{
				new Bonus(locChar, value);
			}
		}
		
		////////////////////////////////////////////////
		// actions
		////////////////////////////////////////////////
		
		public function sendUserAction(actionClass:Class, parameters:Object = null):void
		{
			sendCharAction(clientCharId, actionClass, parameters);
		}
		
		public function sendCharAction(charId:String, actionClass:Class, parameters:Object = null):void
		{
			send('rCharAction', charId, getQualifiedClassName(actionClass), parameters);
		}
		
		public function rCharAction(charId:String, className:String, parameters:Object):void
		{
			if (_bot)
				return;
			
			var actionClass:Class = Class(getDefinitionByName(className));
			
			executeAction(charId, actionClass, parameters);
		}
		
		public function executeAction(charId:String, actionClass:Class, parameters:Object):void
		{
			var locChar:LocationChar = _chars[charId];
			
			if (locChar)
			{
				var action:CharActionBase = new actionClass();
				action.location = this;
				action.char = locChar;
				action.parameters = parameters;
				action.execute();
			}
		}
		
		
		////////////////////////////////////////////////
		// location modifiers
		////////////////////////////////////////////////
		public function rAddLocationModifier(stateId:String, state:Object):void
		{
			var className:String = stateId.replace(KavalokConstants.MODIFIER_PREFIX, '');
			var packageName:String = 'com.kavalok.location.modifiers';
			var fullName:String = packageName + '::' + className;
			var modifierClass:Class = getDefinitionByName(fullName) as Class;
			
			var modifier:LocationModifierBase = new modifierClass();
			modifier.location = this;
			modifier.parameters = state;
			_locationModifiers[stateId] = modifier;
			modifier.apply();
		}
		
		public function rRemoveLocationModifier(stateId:String, state:Object = null):void
		{
			var className:String = stateId;
			var modifier:LocationModifierBase = _locationModifiers[stateId]; 
			if (modifier)
				modifier.restore();
			delete _locationModifiers[className];
		}
		
		public function sendCommand(command:RemoteLocationCommand):void
		{
			send('rExecuteCommand', command.getProperties());
		}
		
		public function rExecuteCommand(commandData:Object):void
		{
			var command:RemoteLocationCommand = RemoteCommand.createInstance(commandData) as RemoteLocationCommand;
			command.location = this;
			command.execute();
		}
		
		////////////////////////////////////////////////
		// object positions
		////////////////////////////////////////////////
		
		public function sendObjectPosition(object:DisplayObject, position:Point):void
		{
			var stateId:String = STATE_POSITION + _children.indexOf(object);
			var state:Object =
			{
				x: position.x,
				y: position.y
			} 
			
			sendState('rObjectPosition', stateId, state);
		}
		
		public function rObjectPosition(stateId:String, state:Object):void
		{
			var objectNum:int = extractObjectNum(stateId);
			if (objectNum >= 0)
			{
				var object:DisplayObject = _children[objectNum];
				TweenLite.to(object, 1.0, {
					x: state.x,
					y: state.y,
					ease: Expo.easeOut
				});
			}
		}
		
		public function sendResetObjectPositions():void
		{
			for (var stateId:String in states)
			{
				if (isPositionState(stateId))
					removeState('rResetObject', stateId);
			}
		}
		
		public function rResetObject(stateId:String):void
		{
			var objectNum:int = extractObjectNum(stateId);
			var object:DisplayObject = _children[objectNum];
			var position:Point = _initioaPositions[objectNum];
			TweenLite.to(object, 1.0, {
				x: position.x,
				y: position.y,
				ease: Expo.easeOut
			});
		}
		
		////////////////////////////////////////////////
		// char modifiers
		////////////////////////////////////////////////
		
		public function sendAddModifier(modifierInfo:Object):void
		{
			sendModifiers();
			send('rAddModifier', clientCharId, modifierInfo);
		}
		
		public function sendRemoveModifier(className:String):void
		{
			sendModifiers();
			send('rRemoveModifier', clientCharId, className);
		}
		
		private function sendModifiers():void
		{
			var state:Object = {};
			state[CharStates.MODIFIERS] = Global.charManager.modifiersList;
			sendUserState(null, state); 
		}
		
		public function rAddModifier(charId:String, modifierInfo:Object):void
		{
			var locChar:LocationChar = _chars[charId];
			if (locChar)
				locChar.addModifier(modifierInfo);
		}
		
		public function rRemoveModifier(charId:String, className:String):void
		{
			var locChar:LocationChar = _chars[charId];
			if (locChar)
				locChar.removeModifier(className);
		}
		
		////////////////////////////////////////////////
		// entry points
		////////////////////////////////////////////////
		
		public function addPoint(point:IEntryPoint):void
		{
			_entryPoints.push(point);
			point.activateEvent.addListener(onPointActivate);
		}
		 
		private function onPointActivate(point:IEntryPoint):void
		{
			tryGoOut();
			_currentPoint = point;
			user.stopMoving();
			var charPosition:Point = point.charPosition; 
			sendMoveUser(charPosition.x, charPosition.y);
		}
		
		public function stopUser():void
		{
			if(user)
				user.stopMoving();
		}
		
		public function getOutFromEntryPoint():void
		{
			tryGoOut();
		}
		
		private function tryGoOut() : void
		{
			if(_activePoint != null)
				_activePoint.goOut();
			
			_activePoint = null;
		}
		
		private function onGroundClick(event : MouseEvent):void
		{
			tryGoOut();
			_currentPoint = null;
			user.stopMoving();
			sendMoveUser(_content.mouseX, _content.mouseY);
		}
		
		protected function onUserMoveComplete():void
		{
			if(_currentPoint != null)
			{
				_currentPoint.goIn();
				_activePoint = _currentPoint;
				_currentPoint = null;
			}
		}
		
		private function initPoints():void
		{
			for (var i:int = 0; i < _content.numChildren; i++)
			{
				var mc:MovieClip = _content.getChildAt(i) as MovieClip;
					
				if (mc && LocationEntryPoint.accept(mc))
				{
					var point:LocationEntryPoint = new LocationEntryPoint(mc);
					addPoint(point);
					
					var prevId:String = Global.locationManager.prevRemoteId;
					
					if (prevId && point.remoteId.toUpperCase() == prevId.toUpperCase())
						_initialCoords = point.charPosition;
				}
			}
		}
		
		private function initStartPoint():void
		{
			var locPoint:MovieClip = _content.getChildByName(DEFAULT_POS_NAME) as MovieClip;
			
			if (locPoint)
			{
				if (!_initialCoords)
				{
					if (locPoint.width > 10)
					{
						_initialCoords = GraphUtils.getRandomZonePoint(locPoint, _content);
					}
					else
					{
						_initialCoords = new Point(
							locPoint.x + Math.random() * 0.5 * POS_DELTA - POS_DELTA,
							locPoint.y + Math.random() * 0.5 * POS_DELTA - POS_DELTA)
					}
				}
					
				_content.removeChild(locPoint);
			}
		}
		
		////////////////////////////////////////////////
		// others
		////////////////////////////////////////////////
		
		private function onIdleTimer(e:TimerEvent):void
		{
			if (user.idleEnabled && _activePoint == null && connected &&
				remote.connectedChars.length < 30)
			{
				var modelType:String = IIdleFactory(user.modelsFactory).randomIdleName;
				sendUserModel(modelType);
			}
		}
		
		protected function modifyChildren(container:DisplayObjectContainer = null):void
		{
			var requirement:IRequirement = new TypeRequirement(MovieClip);
			
			var children:Array = Boolean(container)
				? GraphUtils.getAllChildren(container, requirement)
				: Arrays.getByRequirement(_children, requirement);
			
			for each (var clip:MovieClip in children)
			{
				modifyClip(clip);
			}
		}
		protected function modifyClip(clip : MovieClip):void
		{
			for each (var modifier : IClipModifier in _clipModifiers)
			{
				if (modifier.accept(clip))
					modifier.modify(clip);
			}
		}
		private function onReceiveNotification(notification : Notification):void
		{
			if (_bot)
				return;
			
			var locChar:LocationChar = _chars[notification.fromLogin];
			
			if (locChar && !Global.charManager.ignores.contains(notification.fromLogin))
			{
				if (notification.message is String && locChar.pet
					&& Strings.startsWidth(String(notification.message) + ':', locChar.pet.pet.name))
				{
					var text:String = String(notification.message).substr(locChar.pet.pet.name.length + 1);
					locChar.pet.chatMessage.show(null, text);
				}
				else
				{
					var style:BubbleStyle = (locChar.promotionChatMode)
						? BubbleStyles.getStyle(BubbleStyles.PROMOTION)
						: BubbleStyles.getStyle(locChar.bubbleStyleName);
	
					locChar.chatMessage.show(notification.toLogin, notification.message, style);
				}
			}
		}
		
		private function onCharClick(locChar:LocationChar) : void
		{
			if (!locChar.char.isGuest)
				new ShowCharViewCommand(locChar.id, locChar.userId, locChar.moodId).execute();
		}
		
		////////////////////////////////////////////////
		// dispose
		////////////////////////////////////////////////
		
		public override function charDisconnect(charId:String):void
		{
			super.charDisconnect(charId);
			removeChar(charId);
		}
		
		private function removeChar(charId:String):void
		{
			var locChar:LocationChar = LocationChar(_chars[charId]);
			
			if (locChar)
			{
				if (_predefinedCharsScale == Number.MIN_VALUE)
					updateCharScale();
					
				delete _chars[charId];
				GraphUtils.detachFromDisplay(locChar.content)
				
				if (locChar.pet)
					removePet(locChar.pet);
			}
		}
		
		public function destroy():void
		{
			stopUser();
			
			for each (var locChar:LocationChar in _chars)
			{
				locChar.destroy();
			}	
				
			for each(var point : IEntryPoint in _entryPoints)
			{
				point.destroy();
			}
			
			if (Global.petManager.refreshEvent.hasListener(onPetRefresh))
				Global.petManager.refreshEvent.removeListener(onPetRefresh);
			
			if (_userIdleTimer)
				_userIdleTimer.stop();
			
			if (_petIdleTimer)
				_petIdleTimer.stop();
			
			if(Global.notifications.receiveNotificationEvent.hasListener(onReceiveNotification))
				Global.notifications.receiveNotificationEvent.removeListener(onReceiveNotification);
			RemoteObjects.instance.removeAllClients(_remoteId);
			readyEvent.removeListeners();
			userAdded.removeListeners();
			destroyEvent.sendEvent();
			destroyEvent.removeListeners();
		}
		
		public function updatePerformance():void
		{
			for each (var locChar:LocationChar in _chars)
			{
				locChar.shadowEnabled = Global.performanceManager.shadowEnabled && shadowEnabled;
			}
		}
		
		private function isPositionState(stateId:String):Boolean
		{
			return stateId.indexOf(STATE_POSITION) == 0;
		}
		
		private function extractObjectNum(stateId:String):int
		{
			return parseInt(stateId.replace(STATE_POSITION, ''))
		}
		
		private function isModifierState(stateId:String):Boolean
		{
			return stateId.indexOf(KavalokConstants.MODIFIER_PREFIX) == 0;	
		}
		
		
		////////////////////////////////////////////////
		// getters
		////////////////////////////////////////////////
		
		protected function get initialCoords() : Point
		{
			return _initialCoords;
		}
		
		public function get destroyEvent():EventSender { return _destroyEvent; }
		public function get readyEvent():EventSender { return _readyEvent; }
		public function get userAdded():EventSender { return _userAdded; }
		public function get userPosChanged():EventSender { return _userPosChanged; }
		public function get charAddedEvent():EventSender { return _charAddedEvent; }
		
		public function get locId():String { return _locId; }
		public function get content():Sprite { return _content; }
		public function get chars():Object { return _chars; }
		public function get user():LocationChar { return _user; }
		
		public function get background():Sprite { return _content['background'] };
		public function get entryPoints():Array { return _entryPoints; }
		public function get pathBuilder():PathBuilder { return _pathBuilder; }
		public function get ground():Sprite	{ return _ground; }
		public function get charContainer():Sprite { return _charContainer; }
	}
}
