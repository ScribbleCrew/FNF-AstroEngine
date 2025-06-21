package funkin.game.objects.shaders;

import flixel.system.FlxAssets.FlxShader;

class CustomShader extends FlxShader
{
	public function new(shader:String) : Void
	{
		this.glFragmentSource = shader;
		super();
	}
}
