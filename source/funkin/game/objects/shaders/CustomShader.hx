package funkin.game.objects.shaders;

import flixel.system.FlxAssets.FlxShader;

class CustomShader extends FunkinShader
{
	public function new(?fragmentSource:String, ?vertexSource:String) : Void
	{
		this.glFragmentSource = fragmentSource ?? "";
		this.glVertexSource = vertexSource ?? "	";

		super();
	}
}
