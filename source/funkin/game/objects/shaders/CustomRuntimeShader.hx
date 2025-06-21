package funkin.game.objects.shaders;

import flixel.system.FlxAssets.FlxShader;

class CustomRuntimeShader extends flixel.addons.display.FlxRuntimeShader
{
	public function new(shader:String) : Void
	{
		this.glFragmentSource = shader;
		super();
	}
}
