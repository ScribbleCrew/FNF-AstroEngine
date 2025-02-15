package funkin.backend.system.initialization;

#if MODIFIED_LOGS
import funkin.backend.utils.native.Terminal.TColor;

/**
 * ---------------------------
 * - Modified trace because it just makes sense.
 * Also has a customizable prefix, for example: [System]: <blah blah blah>
 * ---------------------------
 * - Very shit code, soooooo, yeah...
 * ---------------------------
 * - Colors:
 * ```haxe
 * enum TColor
 * {
	BLACK;
	WHITE;
	GRAY;
	RED;
	GREEN;
	BLUE;
	YELLOW;
	CYAN;
	MAGENTA;
	DARKGRAY;
	DARKRED;
	DARKGREEN;
	DARKBLUE;
	DARKYELLOW;
	DARKCYAN;
	DARKMAGENTA;
 * }
 * ```
*/
@:keep class Logs // needs rework ...
{
	/**
	 * `haxe`'s default trace function, stored as a variable for later use.
	 * blah blah blah.
	*/
	public static var defaultTrace:(v:Dynamic, ?infos:Null<PosInfos>) -> Void;

	/**
	 * Custom prefix, mainly used on the loading screen, but can be used anywhere.
	 * If left blank it reverts to its default value, which is `Constants.DEFAULT_LOGS_PREFIX`.
	*/
	public static var prefix(default, set):String = Constants.DEFAULT_LOGS_PREFIX;
	@:dox(hide) @:noCompletion private static function set_prefix(value:String):String
	{
		if (value == '' || value == null) return prefix = Constants.DEFAULT_LOGS_PREFIX;
		return prefix = value;
	}

	/**
	 * Custom trace & print functions which allow traces with color.
	 */
	@:dox(hide) public static function trace(v:Dynamic, ?color:TColor, ?infos:PosInfos)return print(v,color,infos);
	public static function print(v:Dynamic, ?color:TColor, ?infos:PosInfos):Void
	{
		if (color != null) Terminal.instance.fg(color);
		__customTrace(v, infos); // oops :3
		if (color != null) Terminal.instance.resetFg();
	}

	/**
	 * Trace with color + prefix support.
	 */
	public static function prefixedTrace(x:Dynamic, customPrefix:String, ?color:TColor, ?infos:PosInfos):Void
	{
		final _old:String = prefix;
		prefix = customPrefix;
		print(x, color, infos);
		prefix = _old;
	}

	/**
	 * Mainly used for setting up everything.
	 */
	public static function init():Void
	{
		defaultTrace = haxe.Log.trace;
		haxe.Log.trace = __customTrace;
		Logs.prefixedTrace('Finished Setting up custom trace.', 'Logs Client', CYAN);
	}

	/**
	 * Formats the output and returns a better one lol.
	 */
	static function formatOutput(v:Dynamic, ?infos:haxe.PosInfos):String
	{
		if (infos != null && infos.customParams != null)
			for (param in infos.customParams)
				v += ", " + param;
		return '[${prefix}]: $v : ${infos.fileName}:${infos.lineNumber}';
	}

	/**
	 * Da lovely custom trace func.
	 * ---------
	 * SUPPORT:
	 *    Javascript
	 *    Lua
	 *    Windows, Linux, Macos
	 */
	@:dox(hide) @:noCompletion static dynamic function __customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void
	{
		v = formatOutput(v, infos);
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(v);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(v));
		#elseif sys
		Sys.println(v);
		#else
		throw new haxe.exceptions.NotImplementedException();
		#end
	}
}
#end