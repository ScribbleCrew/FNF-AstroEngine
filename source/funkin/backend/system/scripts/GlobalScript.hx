package funkin.backend.system.scripts;

import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;
import haxe.macro.Context;

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
			#if LUA_ALLOWED extensions.set('lua', [".lua", ".funkinlua"]);#end
			#if HSCRIPT_ALLOWED extensions.set('haxe', [".hx", ".hxs"]); /* funi extensions */ #end
		
			Logs.prefixedTrace('Successfully initialized', 'GlobalScript', GREEN);
		}
		catch (error:Dynamic)
			Logs.prefixedTrace('Failed to initialized : $error', 'GlobalScript', RED);
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

	/**
	 * Extension map, contains all file extensions for allowed scripts.	
	 */
	static final extensions:Map<String, Array<String>> = new Map<String, Array<String>>();

	/**
	* Checks if the script's file extension	is inside of the extensions map.
	*/
	static function checkScriptExtensions(file:String, ?type:String):Bool
	{
		// Extension check loop
		for (typeKey in extensions.keys())
		{
			// If 'type' is provided, check only that specific type
			if (type != null && type != typeKey) continue;

			// Check extensions for the current type
			for (ext in extensions.get(typeKey))
			{
				// Check if the file ends with the extension
				if (file.endsWith(ext)) return true;
			}
		}

		// If the extension isn't found
		return false;
	}

	#if (LUA_ALLOWED && HSCRIPT_ALLOWED)
	/**
	 * Set vars on scripts.	
	 */
	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null)
	{
		if (exclusions == null)
			exclusions = [];
		#if LUA_ALLOWED setOnLuas(variable, arg, exclusions); #end
		#if HSCRIPT_ALLOWED setOnHScript(variable, arg, exclusions); #end
	}
	
	/**
	 * Execute class scripts inside of mods/source.
	 * Used inside The BeatStates.
	 */
	public function executeClassScripts(?customClass:String, ?scriptArgs):Void
	{
		// Get the current state's class name.
		final currentClass:Class<Dynamic> = Type.getClass(FlxG.state);
		final _className:String = customClass != null ? customClass : Type.getClassName(currentClass);

		// Convert to lowercase for consistency
		final __className:String = _className.substring(_className.lastIndexOf('.') + 1).toLowerCase(); 
		
		// Loop through all mod folders containing scripts.
		for (folderName in Mods.directoriesWithFile('assets/', 'source/'))
		{
			// Get all files inside the directory
			for (_fileName in FileSystem.readDirectory(folderName))
			{
				// Skip files without valid extensions
				if (!checkScriptExtensions(_fileName)) continue;

				// Combines the folder path with the file name.
				final convertedScriptPath:String = folderName + _fileName;

				// Remove extension and convert to lowercase
				final convertedScriptName:String = _fileName.substr(0, _fileName.lastIndexOf('.')).toLowerCase();

				// Ensure the Global Script (global.hx, or anything that starts with global) runs no matter
				// the state, and scripts that are for specific states run when matching the state name.
				if (convertedScriptName != __className && !convertedScriptName.contains("global")) continue;

				// Execute Lua/HScript scripts if flag concurrent flag is enabled.
				#if LUA_ALLOWED if (checkScriptExtensions(_fileName, "lua")) new FunkinLua(convertedScriptPath).execute(scriptArgs); #end
				#if HSCRIPT_ALLOWED if (checkScriptExtensions(_fileName, "haxe")) new HScript(null, convertedScriptPath).run(scriptArgs); #end
			}
		}
	}
		
	/**
	 * Call on scripts (HScript, Lua)
	 */
	public function callOnScripts(functionName:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null,
			excludeValues:Array<Dynamic> = null):Dynamic
	{
		// Null checks.
		args ??= [];
		exclusions ??= [];
		excludeValues ??= [GlobalScript.functions.Function_Continue];

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
	public function startLuasNamed(luaFile:String):GlobalStatus
	{
		var luaScript:String;

		for (script in luaInstances)
			if (script.scriptName == luaFile)
				return GlobalStatus.ERROR;

		#if MODS_ALLOWED
		luaScript = Paths.modFolders(luaFile);

		FileSystem.exists(luaScript) ? {
			luaInstances.push(new FunkinLua(luaScript).execute());

			return GlobalStatus.SUCCESS;
		} : {
			luaScript = Paths.getSharedPath(luaFile);
			if (FileSystem.exists(luaScript))
			{
				luaInstances.push(new FunkinLua(luaScript).execute());

				return GlobalStatus.SUCCESS;
			}
			}
		#elseif sys
		luaScript = Paths.getSharedPath(luaFile);

		if (OpenFlAssets.exists(luaScript))
		{
			luaInstances.push(new FunkinLua(luaScript).execute());
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
			if (!Iris.instances.exists(scriptToLoad))
				return new HScript(null, scriptToLoad).run();

		return null;
	}

	public function initHScriptHook(filePath:String):GlobalStatus
	{
		var hscriptInstance:HScript = null;

		try
		{
			hscriptInstance = new HScript(null, filePath);
			if (hscriptInstance.exists('onCreate')) hscriptInstance.call('onCreate');
			if(hscriptInstance.exists('create')) hscriptInstance.call('create');
			hscriptInstances.push(hscriptInstance);

			Logs.prefixedTrace('successfully initialized HScript interp on "$filePath"', 'Global Script', GREEN);

			return GlobalStatus.SUCCESS;
		}
		catch (error:IrisError)
		{
			final filePosInfos:HScriptInfos = cast {_fileName: filePath, showLine: false};
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
		for (haxeScript in GlobalScript.instance.hscriptInstances)
		{
			if (haxeScript != null)
			{
				final onDestory:Dynamic = haxeScript.get('onDestroy');
				if (onDestory != null && Reflect.isFunction(onDestory)) 
					onDestory();

				final destory:Dynamic = haxeScript.get('destroy');
				if (destory != null && Reflect.isFunction(destory)) 
					destory();

				haxeScript.destroy();
			}
		}
		GlobalScript.instance.hscriptInstances = [];
		#end
	}

	public function new():Void {}
}

typedef ScriptFunction = Dynamic; // it looks cool, im sowwy :(

@:publicFields class ScriptFunctions
{
	#if (HSCRIPT_ALLOWED || LUA_ALLOWED)
	final Function_Stop:ScriptFunction = "##ASTRO_GLOBALSCRIPT_FUNCTION_STOP";
	final Function_Continue:ScriptFunction = "##ASTRO_GLOBALSCRIPT_FUNCTION_CONTINUE";
	final Function_StopAll:ScriptFunction = "##ASTRO_GLOBALSCRIPT_FUNCTION_STOPALL";

	#if LUA_ALLOWED final Function_StopLua:ScriptFunction = "##ASTRO_GLOBALSCRIPT_FUNCTIONSTOP_LUA"; #end
	#if HSCRIPT_ALLOWED final Function_StopHScript:ScriptFunction = "##ASTRO_GLOBALSCRIPT_FUNCTIONSTOP_HSCRIPT"; #end
	#end
	public function new():Void
	{
	}
}
