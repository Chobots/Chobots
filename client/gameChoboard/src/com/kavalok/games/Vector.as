package com.kavalok.games
{
	
	public class Vector
	{
		public var x:Number;
		public var y:Number;

		public function Vector(px:Number = 0, py:Number = 0)
		{
			x = px;
			y = py;
		}
		
		public function copyVector(v:com.kavalok.games.Vector):void
		{
			x = v.x;
			y = v.y;
		}
		
		public function setMembers( px:Number, py:Number ):void
		{
			x = px;
			y = py;
		}
		
		public function addVector( v:com.kavalok.games.Vector ):void
		{
			x += v.x;
			y += v.y;
		}
		
		public function subVector( v:com.kavalok.games.Vector ):void
		{
			x -= v.x;
			y -= v.y;
		}
		
		public function mulScalar( i:Number ):void
		{
			x *= i;
			y *= i;
		}
		
		public function getMulScalar(i:Number):com.kavalok.games.Vector
		{
			return new com.kavalok.games.Vector(x*i, y*i);
		}
		
		public function magnitude():Number
		{
			return Math.sqrt( x*x + y*y );
		}
		
		public function magnitude2():Number
		{
			return x*x + y*y;
		}
		
		public function vectorProjectionOnto(v:com.kavalok.games.Vector):com.kavalok.games.Vector
		{
			var res:com.kavalok.games.Vector = v.getUnitVector();
			res.mulScalar(scalarProjectionOnto(v));
			return res;
		}
		
		public function getUnitVector():com.kavalok.games.Vector
		{
			var len:Number = magnitude();
			var res:com.kavalok.games.Vector = new com.kavalok.games.Vector(x,y);
			if (len) {
				res.x /= len;
				res.y /= len;
			}
			return res;
		}
		
		// returns the scalar projection of this vector onto v
		public function scalarProjectionOnto(v:com.kavalok.games.Vector):Number
		{
			return (x*v.x + y*v.y)/v.magnitude();
		}
		
		public function toString():String
		{
			return 'Vector(' + x + ', ' + y + ')';
		}
	}
}
