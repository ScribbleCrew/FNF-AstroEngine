package funkin.backend.system.scripts;

/**
 * The return status for scripts.	
 */
enum GlobalStatus
{
	/**
	 * Success (when correctly ran).	
	 */
	SUCCESS;

	/**
	 * Error (error, ofc).	
	 */
	ERROR;

	/**
	 * Unknown (doesn't know what happened).	
	 */
	UNKNOWN;
}

class GlobalScript
{
	/**
	 * Global Script Instance.
	 */
	public static var instance(default, null):GlobalScript = null;

	/**
	 * Script Functions, like `##ASTRO_GLOBALSCRIPT_FUNCTION_CONTINUE`.
	 */
	public static var functions(default, null):ScriptFunctions = null;

	/**
	 * Creates a new instance of `GlobalScript`.
	 */
	public static function init():Void
	{
		try
		{
			instance = new GlobalScript(); // i aint making a constructor
			functions = new ScriptFunctions(); // lazy mf

			Logs.prefixedTrace('Successfully initialized', 'GlobalScript', GREEN);
		}
		catch (error:Dynamic)
			Logs.prefixedTrace('Failed to initialized : $error', 'GlobalScript', RED);

		trace("GlobalScript.instance: " + (GlobalScript.instance != null ? "Exists" : "NULL"));
		trace("hscriptInstances: " + (GlobalScript.instance?.hscriptInstances != null ? "Exists" : "NULL"));
	}

	#if HSCRIPT_ALLOWED
	/**
	 * Contains all HScript instances.
	 */
	public var hscriptInstances:Array<HScript> = [];

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

	#if (LUA_ALLOWED && HSCRIPT_ALLOWED)
	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null)
	{
		if (exclusions == null)
			exclusions = [];
		#if LUA_ALLOWED setOnLuas(variable, arg, exclusions); #end
		#if HSCRIPT_ALLOWED setOnHScript(variable, arg, exclusions); #end
	}

	public function callOnScripts(functionName:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
		if (args == null)
			args = [];
		if (exclusions == null)
			exclusions = [];
		if (excludeValues == null)
			excludeValues = [GlobalScript.functions.Function_Continue];

		var result:Dynamic = #if LUA_ALLOWED callOnLuas(functionName, args, ignoreStops, exclusions, excludeValues) #else null #end;
		#if HSCRIPT_ALLOWED
		if (result == null || excludeValues.contains(result))
			result = callOnHScript(functionName, args, ignoreStops, exclusions, excludeValues);
		#end
		return result;
	}
	#end

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String):GlobalStatus
	{
		var luaScript:String;

		for (script in luaInstances)
			if (script.scriptName == luaFile)
				return GlobalStatus.ERROR;

		#if MODS_ALLOWED
		luaScript = Paths.modFolders(luaFile);

		FileSystem.exists(luaScript) ? {
			luaInstances.push(new FunkinLua(luaScript));

			return GlobalStatus.SUCCESS;
		} : {
			luaScript = Paths.getSharedPath(luaFile);
			if (FileSystem.exists(luaScript))
			{
				luaInstances.push(new FunkinLua(luaScript));

				return GlobalStatus.SUCCESS;
			}
			}
		#elseif sys
		luaScript = Paths.getSharedPath(luaFile);

		if (OpenFlAssets.exists(luaScript))
		{
			luaInstances.push(new FunkinLua(luaScript));
			return GlobalStatus.SUCCESS;
		}
		#end
		return GlobalStatus.ERROR;
	}

	public function callOnLuas(functionName:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
		var returnVal:Dynamic = GlobalScript.functions.Function_Continue;
		#if LUA_ALLOWED
		if (args == null)
			args = [];
		if (exclusions == null)
			exclusions = [];
		if (excludeValues == null)
			excludeValues = [GlobalScript.functions.Function_Continue];

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
			if ((myValue == GlobalScript.functions.Function_StopLua || myValue == GlobalScript.functions.Function_StopAll)
				&& !excludeValues.contains(myValue)
				&& !ignoreStops)
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

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	// "SCRIPTS FOLDER" SCRIPTS
	public function folderLoop(name:String = 'scripts/')
	{
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), name))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if (file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if (file.toLowerCase().endsWith('.hx') || file.toLowerCase().endsWith('.hxs'))
					GlobalScript.instance.initHScriptHook(folder + file);
				#end
			}
	}
	#end

	#if HSCRIPT_ALLOWED
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
		{
			if (Iris.instances.exists(scriptToLoad))
				return false;

			initHScriptHook(scriptToLoad);
			return true;
		}
		return false;
	}
	public function callIndividualHaxe(instance:HScript, e:String, ?args:Null<Array<Dynamic>>) {
		if(instance==null)return;
		if (instance.exists(e))
			instance.call(e,args);
	}
	public function initHScriptHook(filePath:String):GlobalStatus
	{
		var hscriptInstance:HScript = null;

		try
		{
			Logs.prefixedTrace('successfully initialized HScript interp on "$filePath"', 'Global Script', GREEN);

			hscriptInstance = new HScript(null, filePath);
			if (hscriptInstance.exists('onCreate'))
				hscriptInstance.call('onCreate');
			hscriptInstances.push(hscriptInstance);

			return GlobalStatus.SUCCESS;
		}
		catch (error:IrisError)
		{
			final filePosInfos:HScriptInfos = cast {fileName: filePath, showLine: false};
			Iris.error(Printer.errorToString(error, false), filePosInfos);

			hscriptInstance = cast(Iris.instances.get(filePath), HScript);
			if (hscriptInstance != null)
				hscriptInstance.destroy();

			return GlobalStatus.ERROR;
		}

		return GlobalStatus.UNKNOWN;
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
		var returnVal:String = GlobalScript.functions.Function_Continue;

		#if HSCRIPT_ALLOWED
		if (exclusions == null)
			exclusions = new Array();
		if (excludeValues == null)
			excludeValues = new Array();
		excludeValues.push(GlobalScript.functions.Function_Continue);

		final len:Int = hscriptInstances.length;
		if (len < 1)
			return returnVal;

		for (script in hscriptInstances)
		{
			@:privateAccess
			if (script == null || !script.exists(functionName) || exclusions.contains(script.origin))
				continue;

			try
			{
				var callValue = script.call(functionName, args);
				var myValue:Dynamic = callValue.returnValue;

				if ((myValue == GlobalScript.functions.Function_StopHScript || myValue == GlobalScript.functions.Function_StopAll)
					&& !excludeValues.contains(myValue)
					&& !ignoreStops)
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

		for (script in hscriptInstances)
		{
			if (exclusions.contains(script.origin))
				continue;

			// Push to exclude list.
			if (!hscriptExclude.contains(variable))
				hscriptExclude.push(variable);

			// set args
			script.set(variable, arg);
		}
		#end
	}
	#end

	// ignore
	public function new():Void {}
}

@:publicFields class ScriptFunctions
{
	#if (HSCRIPT_ALLOWED || LUA_ALLOWED)
	final Function_Stop:Dynamic = "##ASTRO_GLOBALSCRIPT_FUNCTION_STOP";
	final Function_Continue:Dynamic = "##ASTRO_GLOBALSCRIPT_FUNCTION_CONTINUE";
	final Function_StopAll:Dynamic = "##ASTRO_GLOBALSCRIPT_FUNCTION_STOPALL";

	#if LUA_ALLOWED final Function_StopLua:Dynamic = "##ASTRO_GLOBALSCRIPT_FUNCTIONSTOP_LUA"; #end
	#if HSCRIPT_ALLOWED final Function_StopHScript:Dynamic = "##ASTRO_GLOBALSCRIPT_FUNCTIONSTOP_HSCRIPT"; #end
	#end

	// ignore
	public function new():Void {}
}
