package funkin.backend.system.initialization;

// i hate my life
#if MODIFIED_LOGS
import funkin.backend.utils.native.Terminal.TColor;

/**
 * Modified trace because it just makes sense.
 * Also has a customizable prefix, for example: [System]: \<blah blah blah\>
 */
@:dce final class Logs // needs rework ... - ???/???/??? | IT'S BEEN REWORKED :) - 02/15/25 // NEEDS ANOTHE REWORK...
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
	@:dox(hide) @:noCompletion static var _mutex:Mutex = new Mutex();
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
	public static function trace(v:Dynamic, ?color:TColor, ?infos:PosInfos):Void return print(v, color, infos);
	public static function error(v:Dynamic, ?infos:PosInfos):Void return print(v, RED, infos, " 		ERROR		 ");
	@:dox(hide) @:noCompletion public static function log(v:Dynamic, ?color:TColor, ?infos:PosInfos):Void return print(v, color, infos);
	@:dox(hide) @:noCompletion public static function print(v:Dynamic, ?color:TColor, ?infos:PosInfos, ?prefix:String):Void
	{
		if (color != null)
			Terminal.instance.fg(color);
		__customTrace(v, infos, prefix); // oops :3
		if (color != null)
			Terminal.instance.resetFg();
	}

	/**
	 * Trace with color + prefix support.
	 * (NOTICE: uses threading, only if `THREADING_ALLOWED` is allowed).
	 */
	public static function prefixedTrace(x:Dynamic, ?customPrefix:String, ?color:TColor, ?infos:PosInfos):Void
	{
		#if THREADING_ALLOWED _mutex.acquire(); #end // it looks ugly, ik...
		final prevPrefix:String = prefix;
		prefix = customPrefix ??="null prefix";
		print(x, color, infos);
		prefix = prevPrefix;
		#if THREADING_ALLOWED _mutex.release(); #end
	}

	/**
	 * My stupid initialization function which sets `haxe.Log.trace` to my custom trace 
	 * function `__customTrace`(private).
	 */
	@:allow(funkin.game.Init)
	@:noCompletion static function init():Void
	{
		defaultTrace = haxe.Log.trace;
		//haxe.Log.trace = __customTrace;
		Logs.prefixedTrace('Finished Setting up custom trace.', 'Logs Client', CYAN);
	}

	/**
	 * Formats the output and returns a better one lol.
	 * uses `haxe.PosInfos` to get file info (pretty obvious).
	 */
	@:noCompletion static inline function _formatOutput(v:Dynamic, ?infos:haxe.PosInfos, ?prefix:String):String
	{
		if (infos != null && infos.customParams != null)
			for (param in infos.customParams)
				v += ", " + param;
		return '[${prefix ?? Logs.prefix}]: $v : ${infos.fileName}:${infos.lineNumber}';
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
	@:dox(hide) @:noCompletion static dynamic function __customTrace(v:Dynamic, ?infos:haxe.PosInfos, ?prefix:String):Void
	{
		v = _formatOutput(v, infos, prefix);
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
