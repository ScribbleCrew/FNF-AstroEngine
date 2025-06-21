package funkin.game.objects.shaders;

import flixel.system.FlxAssets.FlxShader;

class CustomShader extends flixel.addons.display.FlxRuntimeShader
{
	public function new(shader:String) : Void
	{
		this.glFragmentSource = shader;
		super();
	}
}
