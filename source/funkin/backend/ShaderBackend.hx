package funkin.backend;

/**
 * All non runtime shaders should extend from this abstract class.
 */
@:access(funkin.backend.system.MusicBeatState._shaderGroup)
abstract class ShaderBackend extends flixel.system.FlxAssets.FlxShader
{
	/**
	 * Constructor function.
	 */
	public function new():Void
	{
		/**
		 * Call the parent constructor
		 */
		super();

		/**
		 * Check if the current state is an instance of MusicBeatState	
		 */
		if (Std.is(flixel.FlxG.state, MusicBeatState))
		{
			/**
			 * Grabs the current state from `FlxG.state`.
			 */
			final currentState:MusicBeatState = cast(flixel.FlxG.state, MusicBeatState);

			/**
			 * If `_shaderGroup` equals null set it to `[]`.
			 */
			currentState._shaderGroup ??= [];

			/**
			 * Pushes `this` to `_shadeGroup`.
			 */
			currentState._shaderGroup.push(this);
		}
	}

	/**
	 * Update function.	
	 */
	@:dox(hide) function update(elapsed:Float):Void {}
}
