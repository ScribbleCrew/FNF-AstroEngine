package funkin.backend.system.scripts;

import hscript.Expr;

typedef ErrColorCodes = {
	var error:String;
	var color:Int;
}

abstract ErrorEnumerator(ErrColorCodes) from ErrColorCodes to ErrColorCodes {// i aint changing the name ;3c
	public static var WARN:ErrorEnumerator = new ErrorEnumerator({error: "WARNING", color: FlxColor.YELLOW});
	public static var ERROR:ErrorEnumerator = new ErrorEnumerator({error: "ERROR", color: FlxColor.RED});
	public static var FATAL:ErrorEnumerator = new ErrorEnumerator({error: "FATAL", color: 0xFFBB0000});// maybe into a json?

	public inline function new(data:ErrColorCodes)
		this = data;

	public inline function getError():String return this.error;
	public inline function getColor():Int return this.color;
}

class ScriptedErrors
{
	public static function errorToString(e: Error, showPos: Bool = true) {// stolen from hscript-iris :p
		var message = switch (#if hscriptPos e.e #else e #end) {
			case EInvalidChar(c): "Invalid character: '" + (StringTools.isEof(c) ? "EOF" : String.fromCharCode(c)) + "' (" + c + ")";
			case EUnexpected(s): "Unexpected token: \"" + s + "\"";
			case EUnterminatedString: "Unterminated string";
			case EUnterminatedComment: "Unterminated comment";
			case EInvalidPreprocessor(str): "Invalid preprocessor (" + str + ")";
			case EUnknownVariable(v): "Unknown variable: " + v;
			case EInvalidIterator(v): "Invalid iterator: " + v;
			case EInvalidOp(op): "Invalid operator: " + op;
			case EInvalidAccess(f): "Invalid access to field " + f;
			case ECustom(msg): msg;
			default: "Unknown Error.";
		};
		#if hscriptPos
		if (showPos)
			return e.origin + ":" + e.line + ": " + message;
		else
			return message;
		#else
		return message;
		#end
	}
	
	public static function warn(x, ?pos:haxe.PosInfos):Void err_return(ErrorEnumerator.WARN, x, pos);
	public static function error(x, ?pos:haxe.PosInfos):Void  err_return(ErrorEnumerator.ERROR, x, pos);
	public static function fatal(x, ?pos:haxe.PosInfos):Void err_return(ErrorEnumerator.FATAL, x, pos);

	private static function err_return(type:ErrorEnumerator, ?x:String, ?pos:haxe.PosInfos)
	{
		final hehe = formatError(x, pos);
		//HScriptUtils.onError(x);
		Logs.trace(hehe, RED);
		if (PlayState.instance != null)
			PlayState.instance.addTextToDebug('${type.getError()}: $hehe', type.getColor());
	}

	static function formatError(x, ?pos:haxe.PosInfos):String
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
		if (newPos.showLine == true)
			msgInfo += '${newPos.lineNumber}:';
		msgInfo += ' $x';
		return msgInfo;
	}
}
