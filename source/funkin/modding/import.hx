package funkin.modding;

#if !macro
// BASE SCRIPTING STUFF
import funkin.modding.*;
import funkin.modding.interfaces.*;
import funkin.modding.ScriptUtil.FunctionFlag;
#if HSCRIPT_ALLOWED
// HSCRIPT
import rulescript.*;
import rulescript.parsers.*;
import rulescript.types.Typedefs;
import rulescript.types.ScriptedTypeUtil;
import rulescript.scriptedClass.RuleScriptedClassUtil;
#end
#if LUA_ALLOWED
// LUA
import funkin.modding.FunkinLua;
#end
#end
