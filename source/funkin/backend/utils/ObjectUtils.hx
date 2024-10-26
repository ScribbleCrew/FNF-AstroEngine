package funkin.backend.utils;

class ObjectUtils
{
	/**
	 * Center Object On A Sprite
	 * @param spr Sprite You Want to center.
	 * @param spr2 Sprite you want your sprite to be centered on.
	 * @return Converted Sprite
	**/
	public static function centerOnObject(spr:flixel.FlxObject, spr2:flixel.FlxObject, axes:flixel.util.FlxAxes):flixel.FlxObject
	{
		if (axes.x)
			spr.x = (spr.width - spr2.width) / 2;
		if (axes.y)
			spr.y = (spr.height - spr2.height) / 2;

		return spr;
	}

	/**
	 * Converts string to a FlxAxes.
	 * @param thing1 String in question.
	 * @return FlxAxes
	**/
	public static function convertFlxAxes(thing1:String):flixel.util.FlxAxes
	{
		return switch (thing1.toLowerCase())
		{
			case 'x':
				return flixel.util.FlxAxes.X;
			case 'y':
				return flixel.util.FlxAxes.Y;
			case 'xy':
				return flixel.util.FlxAxes.XY;
			default:
				return NONE;
		}
	}
}
