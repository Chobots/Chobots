package com.kavalok.games
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	public class GameObject
	{
		public var content:MovieClip;
		public var v:com.kavalok.games.Vector = new com.kavalok.games.Vector();
		public var vrot:Number = 0;
		public var acc:com.kavalok.games.Vector = new com.kavalok.games.Vector();
		public var dcc:com.kavalok.games.Vector = new com.kavalok.games.Vector(1, 1);
		public var weight:Number;
		public var radius:Number;
		public var bounds:Rectangle;
		
		public var tag:Object = {};
		
		public function GameObject(content:MovieClip)
		{
			this.content = content;
			radius = 0.5 * content.width;
			weight = radius;
		}
		
		public function distance2(po:Object):Number
		{
			var dx:Number = content.x - po.x;
			var dy:Number = content.y - po.y;
			return dx * dx + dy * dy;
			return dx * dx + dy * dy;
		}
		
		public function distance(po:Object):Number
		{
			var dx:Number = content.x - po.x;
			var dy:Number = content.y - po.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public function accTo(po:Object):void
		{
			var d:Number = distance(po);
			acc.x = (po.x - content.x) / d;
			acc.y = (po.y - content.y) / d;
			v.addVector(acc);
		}
		
		private function pull(po:GameObject):void
		{
			var ball1:GameObject = this;
			var ball2:GameObject = po;
			var tv:com.kavalok.games.Vector = new com.kavalok.games.Vector(ball1.content.x - ball2.content.x, ball1.content.y-ball2.content.y);
			var distance:Number = tv.magnitude();
			var min_distance:Number = ball1.radius + ball2.radius;
			
			if (distance > min_distance)
				return;
			
			tv.mulScalar((0.1+min_distance-distance)/distance);
			ball1.content.x += tv.x;
			ball1.content.y += tv.y;
		}
		
		public function set scale(value:Number):void
		{
			content.scaleX = content.scaleY = value;
		}
		
		public function resolve(po:GameObject):void
		{
			var ball1:GameObject = this;
			var ball2:GameObject = po;
			var b1Velocity:com.kavalok.games.Vector = new com.kavalok.games.Vector(ball1.v.x, ball1.v.y);
			var b2Velocity:com.kavalok.games.Vector = new com.kavalok.games.Vector(ball2.v.x, ball2.v.y);
			var b1Mass:Number     = ball1.weight;
			var b2Mass:Number     = ball2.weight;

			var lineOfSight:com.kavalok.games.Vector = new com.kavalok.games.Vector(ball1.content.x - ball2.content.x,
				ball1.content.y - ball2.content.y);
				
			var v1Prime:com.kavalok.games.Vector = b1Velocity.vectorProjectionOnto(lineOfSight);
			var v2Prime:com.kavalok.games.Vector = b2Velocity.vectorProjectionOnto(lineOfSight);

			var v1Prime2:com.kavalok.games.Vector = new com.kavalok.games.Vector();
			v1Prime2.copyVector(v2Prime);
			v1Prime2.mulScalar(2*b2Mass);
			v1Prime2.addVector(v1Prime.getMulScalar(b1Mass - b2Mass));
			v1Prime2.mulScalar(1.0/(b1Mass + b2Mass));

			var v2Prime2:com.kavalok.games.Vector = new com.kavalok.games.Vector();
			v2Prime2.copyVector(v1Prime);
			v2Prime2.mulScalar(2*b1Mass);
			v2Prime2.subVector(v2Prime.getMulScalar(b1Mass - b2Mass));
			v2Prime2.mulScalar(1.0/(b1Mass + b2Mass));

			v1Prime2.subVector(v1Prime);
			v2Prime2.subVector(v2Prime);

			ball1.v.addVector(v1Prime2);
			ball2.v.addVector(v2Prime2);
			pull(po);
		}
		
		public function collideWith(po:GameObject):Boolean
		{
			var dx:Number = content.x - po.content.x;
			var dy:Number = content.y - po.content.y;
			var d2:Number = dx * dx + dy * dy;
			var r:Number = radius + po.radius;
			return (d2 < r*r);
		}
		
		public function setRandomV(pmin:Number, pmax:Number = 0):void
		{
			if (pmax == 0)
				pmax = pmin;
			
			var rot:Number = Math.random()*2*Math.PI;
			var tv:Number = pmin + Math.random()*(pmax - pmin);
			
			v.x = tv*Math.cos(rot);
			v.y = tv*Math.sin(rot);
		}
		
		public function setRandomPos(bounds:Rectangle):void
		{
			content.x = bounds.x + Math.random() * bounds.width;
			content.y = bounds.y + Math.random() * bounds.height;
		}
		
		public function checkBounds():void
		{
			if (content.x < bounds.left && v.x < 0)
			{
				content.x = bounds.left;
				v.x = -v.x;
			}
			else if (content.x > bounds.right && v.x > 0)
			{
				content.x = bounds.right;
				v.x = -v.x;
			}
			
			if (content.y < bounds.top && v.y < 0)
			{
				content.y = bounds.top;
				v.y = -v.y;
			}
			else if (content.y > bounds.bottom && v.y > 0)
			{
				content.y = bounds.bottom;
				v.y = -v.y;
			}
		}
		
		public function processMov():void
		{
			content.x += v.x;
			content.y += v.y;
			
			v.addVector(acc);
			
			v.x *= dcc.x;
			v.y *= dcc.y;
			
			if (vrot != 0)
				content.rotation += vrot;
		}

	}
}