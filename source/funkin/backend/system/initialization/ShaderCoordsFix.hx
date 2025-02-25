package funkin.backend.system.initialization;

#if SHADERS_ALLOWED
import flixel.FlxG;

/**
 * This class serves as a fix to coord issues when using OpenFL shaders.
 * It listens for da game resizing events and clears caches.
 */
@:keep final class ShaderCoordsFix
{
	/**
	 * Init's da coord fix.
	 */
	@:allow(funkin.game.Init)
	static function init():Void
	{
		// my calm trace func
		Logs.prefixedTrace("Successfully init'd the coords fix.",'OpenFl', PINK);

		// da main show
		FlxG.signals.gameResized.add((w:Int, h:Int) ->
		{
			if (FlxG.cameras != null)
				_clearCamerasCache();

			if (FlxG.game != null)
				_clearSpriteBitmapCache(FlxG.game);
		});
	}

	/**
	 * Clears the cache of all cameras inside `FlxG.cameras.list`.
	 * Uses the function `_clearSpriteBitmapCache`.
	 */
	@:dox(hide)
	@:noCompletion
	@:access(flixel.FlxCamera)//ae
	static function _clearCamerasCache():Void
	{
		for (curCamera in FlxG.cameras.list)
			if (curCamera != null && curCamera.filters != null)
				_clearSpriteBitmapCache(curCamera.flashSprite);
	}

	/**
	 * Clears the sprite's bitmap cache by setting its `__cacheBitmap`
	 * and `__cacheBitmapData` to `null`.
	 *
	 * @param sprite The sprite whose cache should be cleared.
	 */
	@:access(openfl.display.Sprite)
	@:dox(hide)
	@:noCompletion 
	static function _clearSpriteBitmapCache(sprite:openfl.display.Sprite):Void
	{
		try
		{
			if (sprite.__cacheBitmap != null)
				sprite.__cacheBitmap = null;
			if (sprite.__cacheBitmapData != null)
				sprite.__cacheBitmapData = null;
		}
		catch (error:Dynamic)
			Logs.prefixedTrace(error, 'Error', RED);
	}
}
#end
