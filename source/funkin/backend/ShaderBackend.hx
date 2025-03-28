package funkin.backend;

/**
 * All non runtime shaders should extend from this abstract class.
 */
@:access(funkin.backend.system.MusicBeatState._shaderGroup)
abstract class ShaderBackend extends flixel.system.FlxAssets.FlxShader
{
	public function new():Void
	{
		super();

		// Check if the current state is an instance of MusicBeatState.
		if (Std.is(flixel.FlxG.state, MusicBeatState))
		{
			// Grabs the current state from `FlxG.state`.
			final currentState:MusicBeatState = cast(flixel.FlxG.state, MusicBeatState);

			// If `_shaderGroup` equals null set it to `[]`.
			// Pushes `this` to `_shadeGroup`.
			currentState._shaderGroup ??= [];
			currentState._shaderGroup.push(this);
		}
	}

	@:dox(hide) function update(elapsed:Float):Void {}
}
