package funkin.modding;

#if (HSCRIPT_ALLOWED || LUA_ALLOWED)
/**
* Global Script Class...	
*/

// this isn't even a globalscript class
// im so stupid
// dw tho
// once i finish the scriptpack and script classes i'll fix this too!!!

class GlobalScript implements flixel.util.FlxDestroyUtil.IFlxDestroyable #if HSCRIPT_ALLOWED implements IGlobal #end
{
	/**
	 * Global Script Instance.
	 */
	public static var instance(default, null):GlobalScript = null;

	/**
	 * Creates a new instance of `GlobalScript`.
	 */
	public static function init():Void
	{
		try
		{
			instance = new GlobalScript(); // i aint making a constructor

			Logs.prefixedTrace('Successfully initialized', 'GlobalScript', GREEN);
		}
		catch (error:Dynamic)
			Logs.prefixedTrace('Failed to initialized : $error', 'GlobalScript', RED);

		Application.current.window.onClose.add(()-> {
			if(instance != null)
				instance.destroy();
		});
	}

	#if HSCRIPT_ALLOWED
	/**
	 * Contains all HScript instances.
	 */
	public var hscriptInstances:Map<String, Array<HScript>> = [];

	/**
	 * Excludes any HScript instances.
	 */
	private var hscriptExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	/**
	 * An array of all running lua scripts?
	 * i need to check :3c -orbl
	 */
	public var luaInstances:Array<FunkinLua> = [];
	#end

	
	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	/**
	 * Set vars on scripts.	
	 */
	public function set(variable:String, arg:Dynamic, exclusions:Array<String> = null):Void
	{
		exclusions ??= [];

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		try
		{
			#if LUA_ALLOWED setOnLuas(variable, arg, exclusions); #end
			#if HSCRIPT_ALLOWED setOnHScript(variable, arg, exclusions); #end
		}
		catch (error:haxe.Exception)
			Logs.error('{GlobalScript.set}: $error');
		#end
	}

	/**
	 * Call on scripts (HScript, Lua)
	 * @param functionName the event's name
	 * @param args Event Arguments
	 * @param ignoreStop ignore stop events
	 * @param exclusions any call exclusions
	 * @param excludeValues and values which could be excluded
	 */
	public function call(functionName:String, args:Array<Dynamic> = null, ignoreStops:Null<Bool> = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
		
		// Null checks.
		args ??= [];
		exclusions ??= [];
		excludeValues ??= [Function_Continue];

		// calling.
		var scriptCall:Dynamic = #if LUA_ALLOWED callOnLuas(functionName, args, ignoreStops, exclusions, excludeValues) #else null #end;
		#if HSCRIPT_ALLOWED
		if (scriptCall == null || excludeValues.contains(scriptCall))
			scriptCall = callOnHScript(functionName, args, ignoreStops, exclusions, excludeValues);
		#end

		return scriptCall;
	}
	#end

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String):Bool
	{
		var luaScript:String;

		for (script in luaInstances)
			if (script.scriptName == luaFile)
				return false;

		#if MODS_ALLOWED
		luaScript = Paths.modFolders(luaFile);

		FileSystem.exists(luaScript) ? {
			luaInstances.push(new FunkinLua(luaScript).execute());

			return true;
		} : {
			luaScript = Paths.getSharedPath(luaFile);
			if (FileSystem.exists(luaScript))
			{
				luaInstances.push(new FunkinLua(luaScript).execute());

				return true;
			}
			}
		#elseif sys
		luaScript = Paths.getSharedPath(luaFile);

		if (OpenFlAssets.exists(luaScript))
		{
			luaInstances.push(new FunkinLua(luaScript).execute());
			return true;
		}
		#end
		return false;
	}

	public function callOnLuas(functionName:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
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

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null):Void
	{
		if (exclusions == null)
			exclusions = [];

		for (script in luaInstances)
		{
			if (exclusions.contains(script.scriptName))
				continue;
			script.set(variable, arg);
		}
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String, ?customScriptGroup:String)
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
				return new HScript(null, scriptToLoad).run(null, customScriptGroup);

		//	RuleScript.i

		return null;
	}

	public function initHScriptHook(filePath:String):Bool
	{
		var hscriptInstance:HScript = null;

		try
		{
			hscriptInstance = new HScript(null, filePath);
			hscriptInstance.variables.get('onCreate')();
			hscriptInstance.variables.get('create')();
			// hscriptInstances.push(hscriptInstance);

			Logs.prefixedTrace('successfully initialized HScript interp on "$filePath"', 'Global Script', GREEN);

			return true;
		}
		catch (error:hscript.Expr.Error)
		{
			final filePosInfos:HScript.HScriptInfos = cast {_fileName: filePath, showLine: false};
			HScriptedErrors.error(ScriptUtil.errorToString(error, false), filePosInfos);

			hscriptInstance = cast(HScript.instances.get(filePath), HScript);
			if (hscriptInstance != null)
				hscriptInstance.destroy();

			return false;
		}

		return false; // unknown
	}

	/**
	 * Calls a HScript Function.
	 *
	 * @param functionName the name of the function.
	 * @param args args.
	 * @param ignoreStops ignore Stops
	 * @param exclusions Exclusions.
	 */
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

		final uhh:Array<HScript> = hscriptInstances.safeGet(Main.stateName, []);

		final len:Int = uhh.length;
		if (len < 1)
			return returnVal;

		for (script in uhh)
		{
			@:privateAccess
			if (script == null
				|| !script.exists(functionName)
				|| exclusions.contains(script.origin)
				)
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

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null)
	{
		#if HSCRIPT_ALLOWED
		exclusions ??= [];
		final uhh:Array<HScript> = hscriptInstances.safeGet(Main.stateName, []);
		for (script in uhh)
		{
			if (exclusions.contains(script.origin) )
				continue;

			// Push to exclude list.
			if (!hscriptExclude.contains(variable))
				hscriptExclude.push(variable);

			// set args
			script.variables.set(variable, arg);
		}
		#end
	}
	#end

	public function destroy():Void
	{
		#if LUA_ALLOWED
		for (luaScript in GlobalScript.instance.luaInstances)
		{
			luaScript.call('onDestroy', []);
			luaScript.stop();
		}
		GlobalScript.instance.luaInstances = [];
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		final uhh:Array<HScript> = hscriptInstances.safeGet(Main.stateName, []);
		for (haxeScript in uhh)
		{
			if (haxeScript != null)
			{
				final onDestory:Dynamic = haxeScript.variables.get('onDestroy');
				if (onDestory != null && Reflect.isFunction(onDestory))
					onDestory();

				final destory:Dynamic = haxeScript.variables.get('destroy');
				if (destory != null && Reflect.isFunction(destory))
					destory();

				haxeScript.destroy();
			}
		}
		// reset hscript.
		final stateName = Main.stateName;
		if (GlobalScript.instance.hscriptInstances.exists(stateName))
			GlobalScript.instance.hscriptInstances.set(stateName, []);
		#end
	}

	public function new():Void
	{
	}
}
#end