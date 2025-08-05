package com.kavalok.gameplay.frame.bag
{
	import com.kavalok.Global;
	import com.kavalok.char.actions.MagicAction;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.dto.stuff.StuffTypeTO;
	import com.kavalok.events.EventSender;
	import com.kavalok.gameplay.ToolTips;
	import com.kavalok.location.commands.StuffRainCommand;
	import com.kavalok.services.MagicServiceNT;
	import com.kavalok.services.StuffServiceNT;
	import com.kavalok.ui.LoadingSprite;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.Strings;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class MiniMagicView
	{
		static private const MAGIC_PERIOD:int = 15 * 60; //seconds
		
		private var _content:McMagicView = new McMagicView();
		private var _applyEvent:EventSender = new EventSender();
		private var _loading:LoadingSprite;
		
		public function MiniMagicView()
		{
			ToolTips.registerObject(_content.playButton, 'magicPlayButton', ResourceBundles.KAVALOK);
			_content.playButton.addEventListener(MouseEvent.CLICK, onPlayClick);
		}
		
		private function onPlayClick(e:MouseEvent):void
		{
			if(Global.charManager.magicItem){
				Global.locationManager.location.sendUserAction(
					MagicAction, {name: Global.charManager.magicItem});
				new MagicServiceNT().updateMagicDate();
			}else if(Global.charManager.magicStuffItemRain){
				if(Global.charManager.magicStuffItemRainCount>0){
					Global.locationManager.location.sendUserAction(MagicAction);
					new MagicServiceNT().executeMagicRain();
				}
			}
			onResult(0);
			_applyEvent.sendEvent();
		}

		public function refresh():void
		{
			_loading = new LoadingSprite(_content.getBounds(_content));
			_content.addChild(_loading);
			_content.playButton.visible = false;
			_content.textField.visible = false;
			
			new MagicServiceNT(onResult).getMagicPeriod();
		}
		
		private function onResult(period:int):void
		{
			if (_loading)
				GraphUtils.detachFromDisplay(_loading);
			
			_content.playButton.visible = true;
			_content.textField.visible = true;
			
			if (period > MAGIC_PERIOD || period == -1)
			{
				_content.textField.text = Global.messages.magicReady;
				GraphUtils.setBtnEnabled(_content.playButton, true);
			}
			else
			{
				_content.textField.text = Strings.substitute(
					Global.messages.magicNotReady, String(Math.ceil((MAGIC_PERIOD - period) / 60.0)));
				GraphUtils.setBtnEnabled(_content.playButton, false);
			}
		}
		
		public function get applyEvent():EventSender { return _applyEvent; }
		public function get content():MovieClip { return _content; }
	}
}
