package funkin.backend.system.scripts;

import hscript.Expr;

enum abstract FunctionFlag(String) from String to String
{
	final Function_Stop:FunctionFlag = "##ASTRO_GLOBALSCRIPT_FUNCTION_STOP";
	final Function_Continue:FunctionFlag = "##ASTRO_GLOBALSCRIPT_FUNCTION_CONTINUE";
	final Function_StopLua:FunctionFlag = "##ASTRO_GLOBALSCRIPT_FUNCTIONSTOP_LUA";
	final Function_StopHScript:FunctionFlag = "##ASTRO_GLOBALSCRIPT_FUNCTIONSTOP_HSCRIPT";
	final Function_StopAll:FunctionFlag = "##ASTRO_GLOBALSCRIPT_FUNCTION_STOPALL";
}

class ScriptUtil
{
	public static final Function_Stop:FunctionFlag = FunctionFlag.Function_Stop;
	public static final Function_Continue:FunctionFlag = FunctionFlag.Function_Continue;
	public static final Function_StopLua:FunctionFlag = FunctionFlag.Function_StopLua;
	public static final Function_StopHScript:FunctionFlag = FunctionFlag.Function_StopHScript;
	public static final Function_StopAll:FunctionFlag = FunctionFlag.Function_StopAll;

	public static function formatError(x, ?pos:haxe.PosInfos):String
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

	public static function errorToString(e:Error, showPos:Bool = true):String
	{
		final message = switch (#if hscriptPos e.e #else e #end)
		{
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
		return #if hscriptPos (showPos ? (e.origin + ":" + e.line + ": " + message) : message) #else message #end;
	}
}
