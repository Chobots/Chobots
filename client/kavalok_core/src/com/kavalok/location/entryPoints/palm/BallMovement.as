package com.kavalok.location.entryPoints.palm
{
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.location.entryPoints.PalmEntryPoint;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import com.kavalok.utils.Timers;
	
	public class BallMovement
	{
		private static const SPEED : Number = 1;
		private static const PERSPECTIVE_COEFF : Number = 1;
		private static const SCALE_COEFF : Number = 0.0005;
		private static const MAX_DIST : Number = 20;
		
		private var _point : PalmEntryPoint;
		private var _ball : MovieClip;
		private var _ballZ : Number;
		private var _ballY : Number;
		private var _color : String;
		private var _velocity : Point3D;
		private var _targetCoords : Point3D;
		private var _resultHandler : Function;
		private var _palm : MovieClip;
		private var _owner : String;
		
		public function BallMovement(color : String, point : PalmEntryPoint, palm : MovieClip, ball : MovieClip, velocity : Point3D, owner : String, resultHandler : Function)
		{
			_owner = owner;
			_color = color;
			_palm = palm;
			_point = point;
			_ball = ball;
			_velocity = velocity;
			_ball.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_ballZ = 0;
			_ballY = _ball.y;
			_targetCoords = new Point3D(palm.x, palm.y, PalmEntryPoint.TARGET_Z);
			_resultHandler = resultHandler;
		}
		
		private function get targetHit() : Boolean
		{
			if(Math.abs(_targetCoords.x - _ball.x) > MAX_DIST)
				return false;
			if(Math.abs(_targetCoords.y - _ballY) > MAX_DIST)
				return false;
			if(Math.abs(_targetCoords.z - _ballZ) > MAX_DIST)
				return false;
			return true;
		}
		
		private function onEnterFrame(event : Event) : void
		{
			_ball.x += _velocity.x * SPEED;
			_ballY += _velocity.y * SPEED;
			_ball.y += _velocity.y * SPEED;
			_ballZ += _velocity.z * SPEED; 
			_ball.y -= _velocity.z * SPEED * PERSPECTIVE_COEFF;
			_velocity.z += PalmEntryPoint.GRAV_ACC;
			
			
			_ball.scaleX = _ball.scaleY = 1 + _ballZ * SCALE_COEFF;
			if(_ballZ < 0 || _ballY > KavalokConstants.SCREEN_HEIGHT || _ball.x >= KavalokConstants.SCREEN_WIDTH || targetHit)
			{
				_ball.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_ball.gotoAndStop(2);
				Timers.callAfter(_point.removeBall, 300, _point, [_ball]);
				if(_resultHandler != null)
					_resultHandler(targetHit);
			}
			if(targetHit)
			{
				_point.sendRedrawPalm(_color, _palm.name, _owner);
			}
			
		}

	}
}