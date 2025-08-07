package com.kavalok.telescop
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.utils.Cast;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.PhongBitmapMaterial;
	import away3d.primitives.Sphere;
	
	import com.kavalok.gameplay.KavalokConstants;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class EarthScene extends Sprite
	{
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//material objects
		private var material:PhongBitmapMaterial;
		private var moonMaterial:PhongBitmapMaterial;
		
		//scene objects
		private var sphere:Sphere;
		private var moon:Sphere;
		private var spherecontainer:ObjectContainer3D;
		private var mooncontainer:ObjectContainer3D;
		
		//light objects
		private var light:DirectionalLight3D;
		
		//navigation variables
		private var navigate:Boolean = false;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var lastRotationX:Number;
		private var lastRotationY:Number;
		
		/**
		 * Constructor
		 */
		public function EarthScene() 
		{
		}
		
		public function destroy():void
		{
			removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		/**
		 * Global initialise function
		 */
		public function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initLights();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			camera = new Camera3D({zoom:10, focus:100, x:0, y:0, z:-1000});
			
			view = new View3D({scene:scene, camera:camera});
			view.stats = false;
			view.x = KavalokConstants.SCREEN_WIDTH / 2;
			view.y = KavalokConstants.SCREEN_HEIGHT / 2;
			addChild( view );
			
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			material = new PhongBitmapMaterial( Cast.bitmap(EarthTexture), {specular:0.1, shininess:10} );
			moonMaterial = new PhongBitmapMaterial( Cast.bitmap(MoonTexture), {specular:0.1, shininess:10} );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			sphere = new Sphere({ownCanvas:true, material:material, radius:200, segmentsW:18, segmentsH:18});
			spherecontainer = new ObjectContainer3D();
			spherecontainer.addChild(sphere);
			scene.addChild( spherecontainer );
			spherecontainer.x = 10;

			moon = new Sphere({ownCanvas:true, material:moonMaterial, radius:60, segmentsW:9, segmentsH:9})
			mooncontainer = new ObjectContainer3D();
			mooncontainer.addChild(moon);
			mooncontainer.x = KavalokConstants.SCREEN_WIDTH / 16 * 3;
			mooncontainer.y = KavalokConstants.SCREEN_HEIGHT / 8 * 3;
			scene.addChild(mooncontainer);
			
			
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			light = new DirectionalLight3D({x:-100, y:-100, z:-100, ambient:0.2});
			scene.addLight(light);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame( e:Event ):void
		{
			view.render();
			sphere.rotationY += 0.2;
			if (navigate) {
				spherecontainer.rotationX = (mouseY - lastMouseY)/2 + lastRotationX;
				if (spherecontainer.rotationX > 90)
					spherecontainer.rotationX = 90;
				if (spherecontainer.rotationX < -90)
					spherecontainer.rotationX = -90;
				sphere.rotationY = (lastMouseX - mouseX)/2 + lastRotationY;
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseUp(e:MouseEvent):void
		{
			navigate = false;
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseDown(e:MouseEvent):void
		{
			lastRotationX = spherecontainer.rotationX;
			lastRotationY = sphere.rotationY;
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			navigate = true;
		}
		
	}
}