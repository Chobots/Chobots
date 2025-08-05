package com.kavalok.dto.stuff
{
	import flash.net.registerClassAlias;
	import flash.display.Sprite;
	import com.kavalok.gameplay.ResourceSprite;
	import com.kavalok.gameplay.ColorResourceSprite;
	import com.kavalok.utils.SpriteDecorator;
	
	public class StuffTypeTO extends StuffTOBase
	{
		public static function initialize() : void
		{
			registerClassAlias("com.kavalok.dto.stuff.StuffTypeTO", StuffTypeTO);
		}

		public var placement : String;
		public var enabled : Boolean;
		public var robotInfo : Object;
		public var skuInfo : Object;
		public var rainToken:String;
		public var color:int;

		override public function createModel():ResourceSprite
		{
			if (hasColor && color > 0)
				return new ColorResourceSprite(url, MODEL_CLASS_NAME, color, false);
			else
				return super.createModel();
		}

	}
}