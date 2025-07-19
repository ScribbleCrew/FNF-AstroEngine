package funkin.modding;

import funkin.modding.Script.ScriptType as TScript;

class ScriptPack implements IDummy
{
	public static var packInstances:Array<ScriptPack> = [];

	public var scripts:Array<Script> = [];
	public var parent:Dynamic = null;

	public function new():Void
	{
		// super();
		packInstances.push(this);
	}

	public function call(funcToCall:String, ?args:Array<Dynamic>, ?ignoreStops:Bool, ?exclusions:Array<String>, ?excludeValues:Array<Dynamic>,
			?fucker:TScript = BOTH):Dynamic
	{
		fucker ??= BOTH;
		args ??= [];
		exclusions ??= [];
		excludeValues ??= [Function_Continue];

		var scriptCall:Dynamic = null;
		#if LUA_ALLOWED
		if (fucker == LUA || fucker == BOTH)
			scriptCall = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		else
			scriptCall = null;
		#else
		scriptCall = null;
		#end

		#if HSCRIPT_ALLOWED
		if (fucker == HSCRIPT || fucker == BOTH)
			if (scriptCall == null || excludeValues.contains(scriptCall))
				scriptCall = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		#end
		return scriptCall;
	}

	#if LUA_ALLOWED
	public function callOnLuas(functionName:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
		var luaInstances:Array<FunkinLua> = [];
		for (i => x in scripts)
			if (x.type == LUA)
				luaInstances.push(cast(x, funkin.modding.lua.FunkinLua));
		var returnVal:Dynamic = Function_Continue;
		#if LUA_ALLOWED
		if (args == null)
			args = [];
		if (exclusions == null)
			exclusions = [];
		if (excludeValues == null)
			excludeValues = [Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaInstances)
		{
			if (script.closed)
			{
				arr.push(script);
				continue;
			}

			if (exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(functionName, args);
			if ((myValue == Function_StopLua || myValue == Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if (myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if (script.closed)
				arr.push(script);
		}

		if (arr.length > 0)
			for (script in arr)
				luaInstances.remove(script);
		#end
		return returnVal;
	}
	#end

	#if HSCRIPT_ALLOWED
	var hsScripts(get, never):Array<HScript>;

	function get_hsScripts()
	{
		var uhh:Array<HScript> = [];
		for (i => x in scripts)
			if (x.type == HSCRIPT)
				uhh.push(cast(x, HScript));
		return uhh;
	}
	#end

	#if LUA_ALLOWED
	var lusScripts(get, never):Array<FunkinLua>;

	function get_lusScripts()
	{
		var uhh:Array<FunkinLua> = [];
		for (i => x in scripts)
			if (x.type == LUA)
				uhh.push(cast(x, FunkinLua));
		return uhh;
	}
	#end

	public function setParent(parent:Dynamic)
	{
		this.parent = parent;
		for (e in scripts)
			e.setParent(parent);
	}

	#if HSCRIPT_ALLOWED
	public function callOnHScript(functionName:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
		var returnVal:String = Function_Continue;

		#if HSCRIPT_ALLOWED
		if (exclusions == null)
			exclusions = new Array();
		if (excludeValues == null)
			excludeValues = new Array();
		excludeValues.push(Function_Continue);

		final len:Int = hsScripts.length;
		if (len < 1)
			return returnVal;

		for (script in hsScripts)
		{
			@:privateAccess
			if (script == null || !script.exists(functionName) || exclusions.contains(script.origin))
				continue;

			try
			{
				var callValue = script.call(functionName, args);
				var myValue:Dynamic = callValue.returnValue;

				if ((myValue == Function_StopHScript || myValue == Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if (myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
			catch (error:Dynamic)
				PlayState.instance?.addTextToDebug('ERROR (${script.origin}: $functionName) - $error', FlxColor.RED);
		}
		#end

		return returnVal;
	}

	public function startHScriptsNamed(scriptFile:String)
	{
		var scriptToLoad:String;
		#if MODS_ALLOWED
		scriptToLoad = Paths.modFolders(scriptFile);
		if (!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		scriptToLoad = Paths.getSharedPath(scriptFile);
		#end

		if (FileSystem.exists(scriptToLoad))
			if (!HScript.instances.exists(scriptToLoad)) // make my own
				return add(new HScript(null, scriptToLoad).run());

		//	RuleScript.i

		return null;
	}
	#end

	//public static inline function resultIsStop(result:funkin.modding.ScriptUtil.FunctionFlag):Bool
	//	return Function_Stop == result || Function_StopHScript == result || Function_StopAll == result;

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String):Bool
	{
		var luaScript:String;

		for (script in lusScripts)
			if (script.scriptName == luaFile)
				return false;

		#if MODS_ALLOWED
		luaScript = Paths.modFolders(luaFile);

		FileSystem.exists(luaScript) ? {
			add(new FunkinLua(luaScript).execute());

			return true;
		} : {
			luaScript = Paths.getSharedPath(luaFile);
			if (FileSystem.exists(luaScript))
			{
				add(new FunkinLua(luaScript).execute());

				return true;
			}
			}
		#elseif sys
		luaScript = Paths.getSharedPath(luaFile);

		if (OpenFlAssets.exists(luaScript))
		{
			add(new FunkinLua(luaScript).execute());
			return true;
		}
		#end
		return false;
	}
	#end

	public function get(val:String):Dynamic
	{
		for (e in scripts)
		{
			if (e.type == LUA)
				continue;
			final v = e.get(val); // uhm
			if (v != null)
				return v;
		}
		return null;
	}

	public function set(val:String, value:Dynamic, ?fucker:TScript)
	{
		fucker ??= BOTH;
		for (e in scripts)
			if ((fucker == HSCRIPT && e.type == HSCRIPT) || (fucker == LUA && e.type == LUA) || (fucker == BOTH))
				e.set(val, value);
	}

	public function destroy():Void
	{
		packInstances.remove(this);
		for (e in scripts)
			e.stop();

		scripts = [];
		parent = null;
	}

	public function add(script:Script):Script
	{
		scripts.push(script);
		__SupScript(script);
		return script;
	}

	public function remove(script:Script)
		scripts.remove(script);

	public function insert(pos:Int, script:Script):Script
	{
		scripts.insert(pos, script);
		__SupScript(script);
		return script;
	}

	/**
		* Script Setup
		* @param script 
		* @return Void 
				script.setParent(this.parent)
	 */
	public function __SupScript(script:Script):Void
		script.setParent(this.parent);
}
