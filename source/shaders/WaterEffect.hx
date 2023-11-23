package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;

class WaterEffect extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
		uniform float iTime;

		void main()
		{
			vec2 uv = openfl_TextureCoordv;

			float X = uv.x*15.+iTime;
			float Y = uv.y*15.+iTime;
			uv.y += cos(X+Y)*0.005*cos(Y);
			uv.x += sin(X-Y)*0.005*sin(Y);

			gl_FragColor = flixel_texture2D(bitmap,uv);
		}')
	public function new()
	{
		super();
		iTime.value = [0.0];
	}
	
	public function update(elapsed:Float)
	{
		iTime.value[0] += elapsed;
	}
}