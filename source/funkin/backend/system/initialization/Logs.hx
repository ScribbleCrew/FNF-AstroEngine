package funkin.backend.system.initialization;

// i hate my life
#if MODIFIED_LOGS
import funkin.backend.utils.native.Terminal.TColor;

/**
 * Modified trace because it just makes sense.
 * Also has a customizable prefix, for example: [System]: \<blah blah blah\>
 *
 * #### Colors:
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
@:keep class Logs // needs rework ... - ???/???/??? | IT'S BEEN REWORKED :) - 02/15/25
{
	/**
	 * `haxe`'s default trace function, stored as a variable for later use.
	 * blah blah blah.
	 * why is this even here????
	 */
	public static var defaultTrace:(v:Dynamic, ?infos:Null<PosInfos>) -> Void;

	#if THREADING_ALLOWED
	/**
	 * Mutex (used for threading)
	 * gotta love threading <3.
	 * fr.
	 */
	@:dox(hide) @:noCompletion static var mutex:Mutex = new Mutex();
	#end

	/**
	 * Custom prefix, mainly used on the loading screen, but can be used anywhere.
	 * If left blank it reverts to its default value, 
	 * which is `Constants.DEFAULT_LOGS_PREFIX`.
	 */
	public static var prefix(default, set):String = Constants.DEFAULT_LOGS_PREFIX;
	@:dox(hide) @:noCompletion static function set_prefix(value:String):String
		return prefix = ((value == '' || value == null) ? Constants.DEFAULT_LOGS_PREFIX : value);

	/**
	 * Custom trace function which allow traces with color, has a child function 
	 * `print` which is basically the same function.
	 * I'm in love with this functions, its very cute ;3
	 */
	public static function trace(v:Dynamic, ?color:TColor, ?infos:PosInfos):Void return print(v,color,infos);
	@:dox(hide) public static function print(v:Dynamic, ?color:TColor, ?infos:PosInfos):Void
	{
		if (color != null) Terminal.instance.fg(color);
		__customTrace(v, infos); // oops :3
		if (color != null) Terminal.instance.resetFg();
	}

	/**
	 * Trace with color + prefix support.
	 * (NOTICE: uses threading, only if `THREADING_ALLOWED` is allowed).
	 */
	public static function prefixedTrace(x:Dynamic, customPrefix:String, ?color:TColor, ?infos:PosInfos):Void
	{
		#if THREADING_ALLOWED mutex.acquire();#end//it looks ugly, ik...
		final oldPrefix:String = prefix;
		prefix = customPrefix;
		print(x, color, infos);
		prefix = oldPrefix;
		#if THREADING_ALLOWED mutex.release();#end
	}

	/**
	 * My stupid initialization function which sets `haxe.Log.trace` to my custom trace 
	 * function `__customTrace`(private).
	 */
	public static function init():Void
	{
		defaultTrace = haxe.Log.trace;
		haxe.Log.trace = __customTrace;
		Logs.prefixedTrace('Finished Setting up custom trace.', 'Logs Client', CYAN);
	}

	/**
	 * Formats the output and returns a better one lol.
	 * uses `haxe.PosInfos` to get file info (pretty obvious).
	 */
	static function formatOutput(v:Dynamic, ?infos:haxe.PosInfos):String
	{
		if (infos != null && infos.customParams != null)
			for (param in infos.customParams)
				v += ", " + param;
		return '[${prefix}]: $v : ${infos.fileName}:${infos.lineNumber}';
	}

	/**
	 * Custom trace function, very cool, comes without color
	 * support, but it has prefix support by using the `prefix` variable.
	 * #### Supported Platforms:
	 *    - Javascript **(not tested)**
	 *    - Lua **(not tested)**
	 *    - Windows **(tested)**
	 *    - Linux **(not tested)**
	 *    - Macos **(not tested)**
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