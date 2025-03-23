package funkin.backend.system.scripts.custom;

#if HSCRIPT_ALLOWED
@:access(flixel.util.FlxAxes)
class CustomFlxAxes
{
	public static var X(default, null) = FlxAxes.X;
	public static var Y(default, null) = FlxAxes.Y;
	public static var XY(default, null) = FlxAxes.XY;
	public static var NONE(default, null) = FlxAxes.NONE;

	public static function fromBools(x:Bool, y:Bool):FlxAxes
	    return cast FlxAxes.fromBools(x,y);

	public static function fromString(axes:String):FlxAxes
        return cast FlxAxes.fromString(axes);
}
#end