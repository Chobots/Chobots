package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.Matrix;
	
	/**
	 * Animated movie material with DOT3 shading.
	 */
	public class Dot3MovieMaterial extends CompositeMaterial
	{
		private var _shininess:Number;
		private var _specular:Number;
		private var _movieMaterial:MovieMaterial;
		private var _phongShader:CompositeMaterial;
		private var _ambientShader:AmbientShader;
		private var _diffuseDot3Shader:DiffuseDot3Shader;
		private var _specularPhongShader:SpecularPhongShader;
		
		/**
		 * The exponential dropoff value used for specular highlights.
		 */
		public function get shininess():Number
		{
			return _specular;
		}
		
		public function set shininess(val:Number):void
		{
			_shininess = val;
            _specularPhongShader.shininess = val;
		}
		
		/**
		 * Coefficient for specular light level.
		 */
		public function get specular():Number
		{
			return _specular;
		}
		
		public function set specular(val:Number):void
		{
			_specular = val;
            //specularPhongShader.specular = val;
		}
		
        /**
        * Returns the bitmapData object being used as the material normal map.
        */
		public function get normalMap():BitmapData
		{
			return _diffuseDot3Shader.bitmap;
		}
        
        /**
        * Returns the bitmapData object being used as the material texture.
        */
		public function get bitmap():BitmapData
		{
			return _movieMaterial.bitmap;
		}
		
		/**
		 * Creates a new <code>Dot3MovieMaterial</code> object.
		 * 
		 * @param	movie				The movieclip to be used as the material's texture.
		 * @param	normalMap			The bitmapData object to be used as the material's DOT3 map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function Dot3MovieMaterial(movie:Sprite, normalMap:BitmapData, init:Object=null)
		{
			if (init && init.materials)
				delete init.materials;
			
			super(init);
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getNumber("specular", 0.7);
			
			//create new materials
			_movieMaterial = new MovieMaterial(movie, ini);
			_phongShader = new CompositeMaterial({blendMode:BlendMode.MULTIPLY});
			_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			_phongShader.addMaterial(_diffuseDot3Shader = new DiffuseDot3Shader(normalMap, {blendMode:BlendMode.ADD}));
			
			//add to materials array
			addMaterial(_movieMaterial);
			addMaterial(_phongShader);
			//materials.push(specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD}));
			
		}
		
	}
}