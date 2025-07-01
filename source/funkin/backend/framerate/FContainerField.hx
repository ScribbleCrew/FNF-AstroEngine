package funkin.backend.framerate;

class FContainerField extends Sprite
{
	@:noCompletion
	override function __enterFrame(dt:Int):Void
	{
		if (alpha <= 0.05) return;
		super.__enterFrame(dt);
	}
}
