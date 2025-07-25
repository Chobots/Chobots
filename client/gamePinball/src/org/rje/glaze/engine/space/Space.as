/**
 * glaze - 2D rigid body dynamics & game engine
 * Copyright (c) 2008, Richard Jewson
 * 
 * This project also contains work derived from the Chipmunk & APE physics engines.  
 * Copyright (c) 2007 Scott Lembcke
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.rje.glaze.engine.space {
	
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import org.rje.glaze.engine.dynamics.forces.Force;
	import org.rje.glaze.util.*;
	import org.rje.glaze.engine.math.*;
	import org.rje.glaze.engine.dynamics.*;
	import org.rje.glaze.engine.dynamics.joints.*;
	import org.rje.glaze.engine.collision.*;
	import org.rje.glaze.engine.collision.shapes.*;

	public class Space {
		
		public var iterations:int;
		
		public var force:Vector2D;
		public var masslessForce:Vector2D;
		
		private var _damping:Number;
		
		public var frame:int;
		public var stamp:int;
		
		//Set this to define the world boundary.  Once all of a bodies member shapes AABB's stop intersecting
		//with this then the body and shapes are removed from the engine.  This culling uses the executeIntervalFunctions
		//so it only gets executed every 120 frames (its unnessecary overhead to do it every frame)
		public var worldBoundary:AABB;
		
		private const collider:ICollide = new EnhancedCollision();
		
		public var activeBodies:RigidBody;
		public var staticBodies:RigidBody;
		public var activeBodiesCount:int;
		public var staticBodiesCount:int;
		
		public var activeShapes:GeometricShape;
		public var staticShapes:GeometricShape;
		public var activeShapesCount:int;
		public var staticShapesCount:int;
		
		public var joints:Joint;
		public var forces:Force;
		
		public var shapeContactDict:Dictionary;
		public var bodyContactDict:Dictionary;
		
		public var defaultStaticBody:RigidBody;
		
		public var arbiters:Arbiter;
		public var bodyContacts:BodyContact;
		
		public var collectStats:Boolean;

		public var narrowphaseCounter:Counter;
		public var broadphaseCounter:Counter;
		public var arbiterCounter:Counter;
		
		public var fps:int;
		public var pps:int;
		public var dt:Number;
		private var calcdamping:Number;
		private var ticksPerSec:int;
		private var currTime:int;
		private var accumulator:int;
		
		public function Space( fps:int , pps:int , worldBoundary:AABB = null ) {
			
			Contact.contactPool = null;
			Arbiter.arbiterPool = null;
			BodyContact.bodyContactPool = null;
			
			GeometricShape.nextShapeID = 0;
			RigidBody.nextBodyID = 0;
			
			Arbiter.arbiterPool = new Arbiter();
			
			this.fps = fps;
			this.pps = pps;
			ticksPerSec = 1000 / pps;
			dt = 1 / pps;
			
			iterations = 20;
			damping = 0.99;			
			
			force 			= new Vector2D(0,0);
			masslessForce 	= new Vector2D(0,0);
					
			stamp = 0;
			frame = 0;
			
			shapeContactDict = new Dictionary(true);
			bodyContactDict  = new Dictionary(true);
			
			defaultStaticBody = new RigidBody(RigidBody.STATIC_BODY);
			addRigidBody(defaultStaticBody);
			
			this.worldBoundary = (worldBoundary) ? worldBoundary : AABB.createAt(0, 0, 2000, 2000) ;
			
			collectStats 		= true;

			narrowphaseCounter 	= new Counter("Narrow phase");
			broadphaseCounter   = new Counter("");
			arbiterCounter	    = new Counter("Arbiter Processed");
			

		}
		
		public function set damping(dmp:Number):void {
			this._damping = dmp;
			calcdamping = Math.pow(1 / _damping, -dt);
		}
		
		public function step():void {
			var i:int;
			var k:int;
			
			var newTime:int = getTimer();
			var deltaTime:int = newTime - currTime;
			currTime = newTime;
			
			if (deltaTime > 100) deltaTime = 100;
			
			accumulator += deltaTime;
			while (accumulator >= ticksPerSec) {
				accumulator -= ticksPerSec;
				physicsStep();
			}
			
			frame++;
			processBodyContacts();
			execIntervalFunctions();
		}
		
		public function physicsStep():void {
			var shape:GeometricShape;
			var body:RigidBody;
			var arbiter:Arbiter;
			var forceGen:Force;
			var joint:Joint;
			
			var i:int, j:int;
			
			//Apply each registered force
			forceGen = forces;
			while (forceGen) {
				if (forceGen.active) forceGen.eval();
				forceGen = forceGen.next;
			}
			
			//Update each of the bodies
			body = activeBodies;
			while (body) {
				//TODO sleep stuff
				//if (body.putToSleep) body.setSleepState(true);
				//if (body.isSleeping) continue;
				if (!body.isFixed) 
					body.UpdateVelocity(masslessForce, force, calcdamping, dt);
				body = body.next;
			}
			
			
			//Update each of the shapes position and rotation
			shape = activeShapes;
			while (shape) {
				//if (body.isSleeping) continue;
				shape.Update();
				shape = shape.next;
			}
			
			//Execute collision detection
			broadPhase();
			
			/* 
			 * This block does two things:
			 * 1) It removes old arbiters ( >3 steps old) from the arbiters
			 * 2) It calls preStep for the remaning arbiters.
			 */
			arbiter = arbiters;
			var lastArbiter:Arbiter;
			while (arbiter) {
				if (( stamp  - arbiter.stamp ) > 3) {
					
					//Delete the reference in the Dictionary
					delete shapeContactDict[arbiter.hash];
					
					var bodyHash:uint;// = (arbiter.a.body.bodyID * 3344921057) ^ (arbiter.b.body.bodyID * 3344921057);
					if (arbiter.a.body.bodyID < arbiter.b.body.bodyID)
						bodyHash = (arbiter.a.body.bodyID << 16) | arbiter.b.body.bodyID;
					else
						bodyHash = (arbiter.b.body.bodyID << 16) | arbiter.a.body.bodyID;
					
					var bodyContact:BodyContact = bodyContactDict[bodyHash];
					if (bodyContact) {
						if ( --bodyContact.contactCount == 0 ) {
							delete bodyContactDict[bodyHash];
							bodyContact.endContact = true;
						}
					} else {
						trace("oh shit");
					}	
					
					//Remove all contacts from the arbiter a put them back in the pool
					var contact:Contact = arbiter.contacts;
					var nextContact:Contact;
					while (contact) {
						nextContact = contact.next
						contact.next = Contact.contactPool;
						Contact.contactPool = contact;
						contact = nextContact;
					}
					
					//Unlink the arbiter from arbiterLL
					var thisArbiter:Arbiter = arbiter;
					if (arbiter==arbiters) {						//First
						arbiter = arbiters = arbiter.next;
					} else if (arbiter.next == null) {				//Last
						arbiter = lastArbiter.next = null;
					} else {										//Middle
						arbiter = lastArbiter.next = arbiter.next;	
					}
					
					//Put arbiter backinto the arbiter pool
					thisArbiter.next = (Arbiter.arbiterPool == null) ? null : Arbiter.arbiterPool;
					Arbiter.arbiterPool = thisArbiter;
					
					continue;
				} else {
					arbiterCounter.counter ++;
					arbiter.PreStep(pps);
				}
					
				lastArbiter = arbiter;
				arbiter = arbiter.next;
			}
			
			joint = joints;
			while (joint) {
				joint.PreStep(pps);
				joint = joint.next;
			}
			
			/* 
			 * This is where the engine spends 70% of its time.
			 * If you look in Arbiter.ApplyImpuse you will see all the math has be optimized
			 * to an unreadable mess.  I pray there are no bug in here.  The original code is still
			 * in comments.  Not that it helps.
			 */
			for (i = 0; i < iterations; i++) {
				arbiter = arbiters;
				while (arbiter) {
					arbiter.ApplyImpuse();
					arbiter = arbiter.next;
				}
				joint = joints;
				while (joint) {
					joint.ApplyImpuse();
					joint = joint.next;
				}
			}
			
			//Finally, we can update the position on of the body and reset forces
			body = activeBodies;
			while (body) {
				//TODO sleep stuff
				//if (body.isSleeping) continue;
				
				body.UpdatePosition(dt);
				body.resetForces();
				
				body = body.next;
			}
			
			force.x = force.y = 0;
			
			//Increment the stamp
			stamp++;
			
			if (collectStats) {
				narrowphaseCounter.endCycle();
				arbiterCounter.endCycle();
			}
					
		}
		
		public function narrowPhase( s1:GeometricShape , s2:GeometricShape ):Boolean {
			
			//The first part is more of a midphase...
			if  (s1.body == s2.body) return false;
			if  (!(s1.body.layers & s2.body.layers)) return false;
			if  ((s1.body.group && s2.body.group && s1.body.group == s2.body.group)) return false;
				
			narrowphaseCounter.counter++;
			   
			//Computer the shape pair hash, used to ID existing Arbiter in the Dictionary
			//var shapeHash:uint = (s1.shapeID * 3344921057)^(s2.shapeID * 3344921057);
			var shapeHash:uint;
			if (s1.shapeID < s2.shapeID)
				shapeHash = (s1.shapeID << 16) | s2.shapeID;
			else
				shapeHash = (s2.shapeID << 16) | s1.shapeID;
			
			var pairFound:Boolean = true;
			//Search for existing Arbiter
			var pairArbiter:Arbiter = shapeContactDict[shapeHash];
			//If not found then we need to get one from the pool, or if thats empty create a new one
			if (!pairArbiter) {
				if (Arbiter.arbiterPool == null) 
					Arbiter.arbiterPool = pairArbiter = new Arbiter();
				else
					pairArbiter = Arbiter.arbiterPool;
				pairArbiter.assign(s1, s2, stamp);
				pairFound = false;
			} else {
				//For some reason the broadphase sent this query more than once.  If so just exit.
				if (pairArbiter.stamp == stamp) {
					return true;
				}
			}
			
			//Now this is the narrow phase collision detection part
			
			//Reorder shapes by shape type
			if (s1.shapeType > s2.shapeType) {
				var tempShape2:GeometricShape = s1;
				s1 = s2;
				s2 = tempShape2;
			}
			
			var collided:Boolean;
			
			//Choose and call the correct collision function based on the two shapes.  Note this is inlined due
			//to static call overhead.
			if (s1.shapeType == GeometricShape.POLYGON_SHAPE && s2.shapeType == GeometricShape.POLYGON_SHAPE)
				collided = collider.poly2poly(Polygon(s1), Polygon(s2)  , pairArbiter);
			else if (s1.shapeType == GeometricShape.CIRCLE_SHAPE) {
				if (s2.shapeType == GeometricShape.POLYGON_SHAPE)
					collided =  collider.circle2poly(Circle(s1), Polygon(s2), pairArbiter);	
				else if (s2.shapeType == GeometricShape.CIRCLE_SHAPE )
					collided = collider.circle2circle(Circle(s1), Circle(s2), pairArbiter);					
				else if (s2.shapeType == GeometricShape.SEGMENT_SHAPE )
					collided = collider.circle2segment(Circle(s1), Segment(s2), pairArbiter);
			} else if (s1.shapeType == GeometricShape.SEGMENT_SHAPE && s2.shapeType == GeometricShape.POLYGON_SHAPE )
				collided = collider.segment2poly(Segment(s1), Polygon(s2), pairArbiter);
				
			//The narrow phase reported a collision.
			if (collided) {
				if (pairFound) {
					//If this was an exsiting arbiter then update it
					pairArbiter.stamp = stamp;
					//Need to reassign so the correct order is present
					pairArbiter.a = s1;
					pairArbiter.b = s2;
				} else {
					//Otherwise add a new (or recylced) arbiter
					pairArbiter.hash = shapeHash;
					shapeContactDict[shapeHash] = pairArbiter;
					Arbiter.arbiterPool = Arbiter.arbiterPool.next;
					pairArbiter.next = (arbiters == null) ? null : arbiters;
					arbiters = pairArbiter;
				}
				
				var bodyHash:uint;// = (s1.body.bodyID * 3344921057) ^ (s2.body.bodyID * 3344921057);
				if (s1.body.bodyID < s2.body.bodyID)
					bodyHash = (s1.body.bodyID << 16) | s2.body.bodyID;
				else
					bodyHash = (s2.body.bodyID << 16) | s1.body.bodyID;
					
				var bodyContact:BodyContact = bodyContactDict[bodyHash];
				if (bodyContact) {
					if (bodyContact.stamp < stamp) {
						bodyContact.contactCount = 0;
						bodyContact.stamp = stamp;
						if (s1.body.collectArbiters) s1.body.arbiters.length = 0;
						if (s2.body.collectArbiters) s2.body.arbiters.length = 0;
					} 
					bodyContact.contactCount++;
				} else {
					if (BodyContact.bodyContactPool) {
						bodyContact = BodyContact.bodyContactPool;
						BodyContact.bodyContactPool = BodyContact.bodyContactPool.next;
						bodyContact.contactCount = 0;
						bodyContact.startContact = true;
						bodyContact.endContact = false;
					} else {
						bodyContact = new BodyContact();
					}
					bodyContact.stamp = stamp;
					bodyContact.contactCount++;
					bodyContact.bodyA = s1.body;
					bodyContact.bodyB = s2.body;
					bodyContactDict[bodyHash] = bodyContact;
					bodyContact.next = bodyContacts;
					bodyContacts = bodyContact;
				}
				if (s1.body.collectArbiters) s1.body.arbiters.push(pairArbiter);
				if (s2.body.collectArbiters) s2.body.arbiters.push(pairArbiter);
			}
			return collided;
		}
		
		public virtual function processBodyContacts():void {
			
			var bodyContact:BodyContact = bodyContacts;
			var lastBodyContact:BodyContact;
			while (bodyContact) {
				if (bodyContact.bodyA.collisionProcessingMask) {
					if (( bodyContact.bodyA.collisionProcessingMask & 1 )&&(bodyContact.startContact)) bodyContact.bodyA.onStartCollision(bodyContact.bodyB);
					if  ( bodyContact.bodyA.collisionProcessingMask & 2 )  bodyContact.bodyA.onCollision(bodyContact.bodyB);
					if (( bodyContact.bodyA.collisionProcessingMask & 4 )&&(bodyContact.endContact)) bodyContact.bodyA.onEndCollision(bodyContact.bodyB);
				}
				if (bodyContact.bodyB.collisionProcessingMask) {
					if (( bodyContact.bodyB.collisionProcessingMask & 1 )&&(bodyContact.startContact)) bodyContact.bodyB.onStartCollision(bodyContact.bodyA);
					if  ( bodyContact.bodyB.collisionProcessingMask & 2 )  bodyContact.bodyB.onCollision(bodyContact.bodyA);
					if (( bodyContact.bodyB.collisionProcessingMask & 4 )&&(bodyContact.endContact)) bodyContact.bodyB.onEndCollision(bodyContact.bodyA);					
				}
				
				bodyContact.startContact = false;
				
				if (bodyContact.endContact) {
					var thisBodyContact:BodyContact = bodyContact;
					if (bodyContact==bodyContacts) {					//First
						bodyContact = bodyContacts = bodyContact.next;
					} else if (bodyContact.next == null) {				//Last
						bodyContact = lastBodyContact.next = null;
					} else {											//Middle
						bodyContact = lastBodyContact.next = bodyContact.next;	
					}
					thisBodyContact.next = BodyContact.bodyContactPool;
					BodyContact.bodyContactPool = thisBodyContact;
				} else {
					lastBodyContact = bodyContact;
					bodyContact = bodyContact.next;
				}	
			}
		}
		
		public virtual function broadPhase():void {
		}		
		
		public virtual function castRay( ray:Ray ):Boolean {
			return false;
		}
		
		public virtual function getShapeAtPoint( point:Vector2D ):GeometricShape {			
			return null;
		}		
		
		public virtual function sync():void {
			
		}
		
		public virtual function addRigidBody( body:RigidBody ):void {
			
			var shape:GeometricShape;		
			var bodies:RigidBody = body.isStatic ? staticBodies : activeBodies;
			var shapes:GeometricShape = body.isStatic ? staticShapes : activeShapes;
			
			if (bodies == null) {
				bodies = body;
				body.next = body.prev = null;
			} else {
				body.next = bodies;
				body.prev = null;
				bodies.prev = body;
				bodies = body;
			}
			
			for each (shape in body.memberShapes) {
				if (shapes == null) {
					shapes = shape;
					shape.next = shape.prev = null;
				} else {
					shape.next = shapes;
					shapes.prev = shape;
					shapes = shape;
				}
				shape.Update();
			}
			
			if (body.isStatic) {
				staticBodiesCount++;
				staticShapesCount += body.memberShapes.length;
				staticBodies = bodies;
				staticShapes = shapes;
			} else {
				activeBodiesCount++;
				activeShapesCount += body.memberShapes.length;
				activeBodies = bodies;
				activeShapes = shapes;				
			}
			
			body.registerSpace(this);
		
		}
		
		public virtual function removeRigidBody( body:RigidBody ):void {

			var shape:GeometricShape;
			var bodies:RigidBody = body.isStatic ? staticBodies : activeBodies;
			var shapes:GeometricShape = body.isStatic ? staticShapes : activeShapes;
			
			if (!body.prev) {
			   bodies = body.next
			} else {
			   body.prev.next = body.next
			}
			if (body.next) {
			   body.next.prev = body.prev
			}

			for each (shape in body.memberShapes) {
				if (!shape.prev) {
					shapes = shape.next;
				} else {
					shape.prev.next = shape.next;
				}
				
				if (shape.next) {
				   shape.next.prev = shape.prev
				}
			}
			
			if (body.isStatic) {
				staticBodiesCount--;
				staticShapesCount -= body.memberShapes.length;
				staticBodies = bodies;
				staticShapes = shapes;
			} else {
				activeBodiesCount--;
				activeShapesCount -= body.memberShapes.length;
				activeBodies = bodies;
				activeShapes = shapes;				
			}
			/*
			if (body.fixed) {
				
				if (!body.prev) {
				   staticBodies = body.next
				} else {
				   body.prev.next = body.next
				}
				if (body.next) {
				   body.next.prev = body.prev
				}
				staticBodiesCount--;

				for each (shape in body.memberShapes) {
					if (!shape.prev) staticShapes = shape.next else shape.prev.next = shape.next;
					
					if (shape.next) {
					   shape.next.prev = shape.prev
					}
					staticShapesCount--;
				}
				
			} else {
				
				if (!body.prev) {
				   activeBodies = body.next
				} else {
				   body.prev.next = body.next
				}
				if (body.next) {
				   body.next.prev = body.prev
				}
				activeBodiesCount--;

				for each (shape in body.memberShapes) {
					if (!shape.prev) {
					   activeShapes = shape.next
					} else {
					   shape.prev.next = shape.next
					}
					if (shape.next) {
					   shape.next.prev = shape.prev
					}
					activeShapesCount--;
				}				
			}
			*/
			
			//var bodies:RigidBody      = body.fixed ? staticBodies : activeBodies;
			//var shapes:GeometricShape = body.fixed ? staticShapes : activeShapes;
			
			/*
			var bodyArray:Array  = body.fixed ? staticBodies : activeBodies;
			var shapeArray:Array = body.fixed ? staticShapes : activeShapes;
			
			var index:int = bodyArray.indexOf(body);
			if (index >= 0) {
				bodyArray.splice(index, 1);
				var shape:GeometricShape;
				for each (shape in body.memberShapes) {
					index = shapeArray.indexOf(shape);
					if (index >= 0)
						shapeArray.splice(index, 1);
				}
			}
			body.unregisterSpace();
			*/
		}

		public virtual function addJoint( joint:Joint ):void {
			if (joints == null) {
				joints = joint;
				joint.next = joint.prev = null;
			} else {
				joint.next = joints;
				joint.prev = null;
				joints.prev = joint;
				joints = joint;
			}
		}		

		public virtual function removeJoint( joint:Joint ):void {
			if (!joint.prev) {
			   joints = joint.next
			} else {
			   joint.prev.next = joint.next
			}
			if (force.next) {
			   joint.next.prev = joint.prev
			}
		}		
		
		public virtual function addForce( force:Force ):void {
			if (forces == null) {
				forces = force;
				force.next = force.prev = null;
			} else {
				force.next = forces;
				force.prev = null;
				forces.prev = force;
				forces = force;
			}
		}
		
		public virtual function removeForce( force:Force ):void {
			if (!force.prev) {
			   forces = force.next
			} else {
			   force.prev.next = force.next
			}
			if (force.next) {
			   force.next.prev = force.prev
			}
		}
		
		public virtual function execIntervalFunctions():void {
			if ( frame % 10 == 0 ) cullOutOfBounds();
			
		}
		
		public function cullOutOfBounds():void {
			var body:RigidBody = activeBodies;
			var shape:GeometricShape;
			
			var numShapes:int;
			var cull:Boolean;
			while (body) {
				cull = true;
				numShapes = body.memberShapes.length;
				for (var j:int = 0; j < numShapes; j++) {
					shape = body.memberShapes[j];
					if (!(worldBoundary.l > shape.aabb.r || worldBoundary.r < shape.aabb.l || worldBoundary.t > shape.aabb.b || worldBoundary.b < shape.aabb.t)) {
						cull = false;
						break;
					}
				}
				if (cull) {
					var nextBody:RigidBody = body.next;
					removeRigidBody(body);
					body = nextBody;
				} else {
					body = body.next;
				}
			}	
		}
			
	}
	
}
