package funkin.modding.hscript;
#if HSCRIPT_ALLOWED
typedef ErrorDataType =
{
	var error:String;
	var color:Int;
}

abstract ErrorAbstract(ErrorDataType) from ErrorDataType to ErrorDataType
{ // i aint changing the name ;3c
	public static var WARN:ErrorAbstract = new ErrorAbstract({error: "WARNING", color: FlxColor.YELLOW});
	public static var ERROR:ErrorAbstract = new ErrorAbstract({error: "ERROR", color: FlxColor.RED});
	public static var FATAL:ErrorAbstract = new ErrorAbstract({error: "FATAL", color: 0xFFBB0000}); // maybe into a json?

	public inline function new(data:ErrorDataType):ErrorAbstract
		this = data;

	public inline function getError():String
		return this.error;

	public inline function getColor():Int
		return this.color;
}

class HScriptedErrors
{
	/**
	 * Warn Error Function.	
	 */
	public static function warn(x, ?pos:haxe.PosInfos):Void
	{
		__regErr(ErrorAbstract.WARN, x, pos);
	}

	/**
	 * The Error Function.	
	 */
	public static function error(x, ?pos:haxe.PosInfos):Void
	{
		__regErr(ErrorAbstract.ERROR, x, pos);
	}

	/**
	 * Fatal Error Function.	
	 */
	public static function fatal(x, ?pos:haxe.PosInfos):Void
	{
		__regErr(ErrorAbstract.FATAL, x, pos);
	}

	@:dox(hide) @:noCompletion static function __regErr(type:ErrorAbstract, ?x:String, ?pos:haxe.PosInfos)
	{
		final hehe = ScriptUtil.formatError(x, pos);
		Logs.error(hehe);
		// HScriptUtils.onError(x);
		if (PlayState.instance != null)
			PlayState.instance.addTextToDebug('${type.getError()}: $hehe', type.getColor());
	}
}
#end