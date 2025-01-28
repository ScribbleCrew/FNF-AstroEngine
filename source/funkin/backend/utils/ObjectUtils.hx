package funkin.backend.utils;

class ObjectUtils
{
	/**
	 * Center object on another sprite.
	 *
	 * @param spr Sprite you want to center.
	 * @param spr2 Sprite you want your sprite to be centered on.
	 *
	 * @return Converted sprite.
	 */
	public static inline function centerOnObject(spr:flixel.FlxObject, spr2:flixel.FlxObject, axes:flixel.util.FlxAxes = XY):flixel.FlxObject
	{
		if (axes.x)
			spr.x = spr2.width / 2 - spr.width / 2;
		if (axes.y)
			spr.y = (spr2.height / 2) - (spr.height / 2);

		return spr;
	}

	/**
	 * Sort strumTime by time.
	 *
	 * @param Obj1 Obj1.
	 * @param Obj2 Obj2.
	 *
	 * @return FlxSort.
	 */
	public static inline function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return flixel.util.FlxSort.byValues(flixel.util.FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	/**
	 * Converts given string to a FlxAxes.
	 *
	 * @param inputStr String in question.
	 *
	 * @return FlxAxes
	 */
	public static inline function convertFlxAxes(inputStr:String):flixel.util.FlxAxes
	{
		return switch (inputStr.toLowerCase())
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
