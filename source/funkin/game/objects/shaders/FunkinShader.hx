package funkin.game.objects.shaders;

import flixel.system.FlxAssets.FlxShader;
import rulescript.types.IRuleScriptCustomAccessor;

class FunkinShader extends FlxShader implements IRuleScriptCustomAccessor
{
	@:dox(hide) @:noCompletion static final __instanceFields = Type.getInstanceFields(FunkinShader);

	public function new(?fragmentSource:String, ?vertexSource:String):Void
	{
		this.glFragmentSource = fragmentSource ?? "";
		this.glVertexSource = vertexSource ?? "	";

		super();
	}

	public function setField(id:String, value:Dynamic):Dynamic
	{
		// TODO:

		return -1;
	}

	public function getField(id:String):Dynamic
	{
		// TODO:

		return -1;
	}
}
