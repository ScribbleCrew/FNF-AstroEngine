package funkin.backend.initialization;


/**
 * Modified trace because it just makes sense.
 * Also has a customizable prefix, for example: [System]: <blah blah blah>
 */
class Logs
{
    /**
     * Custom prefix, mainly used on the loading screen, but can be used anywhere.
     * If left blank it reverts to its default value, which is `Constants.DEFAULT_LOGS_PREFIX`.
     */
	public static var prefix(default, set):String = Constants.DEFAULT_LOGS_PREFIX;
	@:dox(hide) @:noCompletion private static function set_prefix(value:String):String {
		if (value == '' || value == null) return prefix = Constants.DEFAULT_LOGS_PREFIX;
		return prefix = value;
	}

	/**
	 * Mainly used for setting up everything.
	 */
	public static function init():Void
	{
		haxe.Log.trace = __customTrace;
        Logs.prefix = 'Initialization';
		trace('Finished Setting up custom trace.');
	}

	@:dox(hide) @:noCompletion private static function __customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void
	{
		var extra:String = "";
		if (infos != null && infos.customParams != null)
			for (param in infos.customParams)
				extra += ", " + param;

		final logThing:String = '[${prefix}]: ${v + (extra == "" ? '' : extra)} : ${infos.fileName + ":" + infos.lineNumber}';

		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(logThing);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(logThing));
		#elseif sys
		Sys.println(logThing);
		#else
		throw new haxe.exceptions.NotImplementedException();
		#end
	}
}
