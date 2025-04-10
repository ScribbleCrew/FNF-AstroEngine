package funkin.backend.system.scripts;

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
}