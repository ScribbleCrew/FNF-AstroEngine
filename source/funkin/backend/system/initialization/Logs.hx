package funkin.backend.system.initialization;

import funkin.backend.utils.native.Terminal.TColor;

/**
 * Modified trace because it just makes sense.
 * Also has a customizable prefix, for example: [System]: <blah blah blah>
 */
class Logs // needs rework ...
{
	/**
	 * Custom prefix, mainly used on the loading screen, but can be used anywhere.
	 * If left blank it reverts to its default value, which is `Constants.DEFAULT_LOGS_PREFIX`.
	 */
	public static var prefix(default, set):String = Constants.DEFAULT_LOGS_PREFIX;

	@:dox(hide) @:noCompletion private static function set_prefix(value:String):String
	{
		if (value == '' || value == null)
			return prefix = Constants.DEFAULT_LOGS_PREFIX;
		return prefix = value;
	}

	public static function print(v:Dynamic, ?color:TColor, ?infos:PosInfos) // sorry but, you don't need PosInfo lmao
	{
		trace(infos.className);
		if (color != null)
			Terminal.instance.fg(color);
		trace(v, infos);
		if (color != null)
			Terminal.instance.resetFg();
	}

	public static function prefixedTrace(x:Dynamic, customPrefix:String, ?color:TColor, ?infos:PosInfos)
	{
		var _old:String = prefix;
		prefix = customPrefix;
		print(x, color);
		prefix = _old;
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

	@:dox(hide) @:noCompletion private static dynamic function __customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void
	{
		var extra:String = "";
		// FUCK YOU :3c
		// if (infos != null && infos.customParams != null)
		// 	for (param in infos.customParams)
		// 		extra += ", " + param;

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
