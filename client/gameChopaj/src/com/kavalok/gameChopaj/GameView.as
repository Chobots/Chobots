package com.kavalok.gameChopaj
{
	import com.kavalok.char.Char;
	import com.kavalok.char.CharModel;
	import com.kavalok.char.CharModels;
	import com.kavalok.gameChopaj.data.PlayerData;
	import com.kavalok.Global;
	import com.kavalok.events.EventSender;
	import com.kavalok.gameChopaj.Controller;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.utils.DragManager;
	import com.kavalok.utils.GraphUtils;
	import flash.text.TextField;
	import gameChopaj.McPlayerFilters;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import gameChopaj.McGameWindow;

	
	public class GameView extends Controller
	{
		static private const MODEL_SCALE:Number = 1.5;
		
		private var _closeEvent:EventSender = new EventSender();
		
		private var _models:Array = [];
		private var _activeModel:CharModel;
		private var _activeFilters:Array;
		private var _content:McGameWindow = game.content;
		
		public function GameView()
		{
			new DragManager(_content, _content.background, KavalokConstants.SCREEN_RECT);
			
			_content.closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			_activeFilters = GraphUtils.getFilters(McPlayerFilters);
			
			_content.myPosition.visible = false;
			_content.hisPosition.visible = false;
			_content.myName.text = '';
			_content.hisName.text = '';
		}
		
		public function setDancePlayer(playerNum:int):void
		{
			setActiveModel(null);
			
			if (playerNum == -1)
			{
				if (_models[0] != null)
					CharModel(_models[0]).setModel(CharModels.DANCE_VICTORY);
				if (_models[1] != null)
					CharModel(_models[1]).setModel(CharModels.DANCE_VICTORY);
			}
			else
			{
				if (_models[playerNum] != null)
					CharModel(_models[playerNum]).setModel(CharModels.DANCE_VICTORY);
			}
		}
		
		public function addPlayer(data:PlayerData):void
		{
			var char:Char = new Char(data);
			var model:CharModel = new CharModel(char);
			model.scale = MODEL_SCALE;
			model.refresh();
			
			_content.addChild(model);
			
			var atBottom:Boolean = game.playerNum == data.playerNum
								|| game.playerNum == -1 && data.playerNum == 0;
			
			var nameField:TextField = atBottom
				? _content.myName
				: _content.hisName;
				
			var position:Sprite = atBottom
				? _content.myPosition
				: _content.hisPosition;
			
			
			nameField.text = char.id;
			GraphUtils.setCoords(model, position);
			
			_models[data.playerNum] = model;
		}
		
		public function removePalyer(playerNum:int):void
		{
			GraphUtils.detachFromDisplay(_models[playerNum]);
			setActiveModel(null);
			_models[playerNum] = null;
		}
		
		public function setActivePlayer(playerNum:int):void
		{
			setActiveModel(_models[playerNum]);
		}
		
		private function setActiveModel(model:CharModel):void
		{
			if (_activeModel)
				_activeModel.filters = [];
			
			_activeModel = model;
			
			if (_activeModel)
				_activeModel.filters = _activeFilters;
		}
		
		private function onCloseClick(e:MouseEvent):void
		{
			_closeEvent.sendEvent();
		}
		
		public function get closeEvent():EventSender { return _closeEvent; }
	}
	
}