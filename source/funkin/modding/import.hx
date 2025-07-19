package funkin.modding;

#if !macro
// BASE SCRIPTING STUFF
import funkin.modding.*;
import funkin.modding.interfaces.*;
import funkin.modding.interfaces.scriptTypes.*;
import funkin.modding.ScriptUtil;
#if (HSCRIPT_ALLOWED || LUA_ALLOWED)
import funkin.modding.ScriptUtil.FunctionFlag;
#end
#if HSCRIPT_ALLOWED
// HSCRIPT
import rulescript.*;
import rulescript.parsers.*;
import rulescript.types.Typedefs;
import rulescript.types.ScriptedTypeUtil;
import rulescript.scriptedClass.RuleScriptedClassUtil;

import funkin.modding.hscript.*;
#end
#if LUA_ALLOWED
// LUA
import funkin.modding.lua.*;
#else
import funkin.modding.lua.LuaUtils;
#end
#end
