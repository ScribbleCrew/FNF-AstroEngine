package funkin.backend.system.initialization;
#if HSCRIPT_ALLOWED
class IrisConfig// convert to hscript utils
{
	public static function init() : Void
	{
		Iris.warn = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(WARN, x, pos);
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: ${formatError(x, pos)}', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(ERROR, x, pos);
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: ${formatError(x, pos)}', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(FATAL, x, pos);
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: ${formatError(x, pos)}', 0xFFBB0000);
		}
	}

	static function formatError(x, ?pos:haxe.PosInfos) : String
	{
		final newPos:HScriptInfos = cast pos;
		if (newPos.showLine == null)
			newPos.showLine = true;

		var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '') + '${newPos.fileName}:';
		#if LUA_ALLOWED
		if (newPos.isLua == true)
		{
			msgInfo += 'HScript:';
			newPos.showLine = false;
		}
		#end
		if (newPos.showLine == true) msgInfo += '${newPos.lineNumber}:';
		msgInfo += ' $x';
		return msgInfo;
	}
}
#end
