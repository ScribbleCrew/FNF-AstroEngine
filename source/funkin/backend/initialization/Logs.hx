package funkin.backend.initialization;


/**
 * Modded trace because it just makes sense.
 * Also has a customizable prefix, example: [SYSTEM]: <blah blah blah>
 */
class Logs // Modded trace func
{
    /**
     * Custom prefix, mainly used on the loading screen, but can be used anywhere.
     * If left blank it reverts to its default value, which is `Constants.DEFAULT_LOGS_PREFIX`.
     */
	public static var prefix(default, set):String = Constants.DEFAULT_LOGS_PREFIX;
	@:dox(hide) @:noCompletion private static function set_prefix(yeah:String):String {
		if (yeah == '' || yeah == null) return prefix = Constants.DEFAULT_LOGS_PREFIX;
		return prefix = yeah;
	}


	public static function init():Void
	{
		haxe.Log.trace = __customTrace;
        Logs.prefix = 'INIT';
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
