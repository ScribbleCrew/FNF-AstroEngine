package funkin.backend.initialization;


/**
* Modded trace because it just makes sense.
* Also has a changeable prefix exmp: [SYSTEM]: <blah blah blah>
*
* @author YourFriendOrbl
*/
class Logs // Modded trace func
{
	public static var prefix(default, set):String = Constants.DEFAULT_LOGS_PREFIX;
	@:noCompletion private static function set_prefix(yeah:String):String {
		if (yeah == '' || yeah == null) return prefix = Constants.DEFAULT_LOGS_PREFIX;
		return prefix = yeah;
	}


	public static function init():Void
	{
		haxe.Log.trace = __customTrace;
        Logs.prefix = 'INIT';
		trace('Finished Setting up custom trace.');
	}

	@:noCompletion private static function __customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void
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
