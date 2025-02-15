package funkin.backend.system.initialization;
// shader coords fix
@:keep class ShaderCoordsFix
{
	public static function fix():Void
	{
		FlxG.signals.gameResized.add(function(width, height)
		{
			if (FlxG.cameras != null)
				for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
						_clearCache(cam.flashSprite);

			if (FlxG.game != null)
				_clearCache(FlxG.game);
		});
	}

	@:access(openfl.display.Sprite)
	@:dox(hide) @:noCompletion private static function _clearCache(sprite:openfl.display.Sprite):Void
	{
		untyped Logs.trace('color test 123', MAGENTA);
		sprite.__cacheBitmap = null;
		sprite.__cacheBitmapData = null;
	}
}
