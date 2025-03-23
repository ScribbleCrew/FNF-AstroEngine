package funkin.game.states.owo;

#if ASTRO_WATERMARKS
@:access(funkin.game.FPS)
class VeryFuniState extends MusicBeatState
{
	@:noCompletion var _return(default, null):FlxState = null;

	public function new(?_return:FlxState):Void
	{
		super();
		this._return = _return;
	}
}
#end
