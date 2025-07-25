package funkin.modding.hscript;

import haxe.io.Path;
#if LUA_ALLOWED import funkin.modding.lua.FunkinLua; #end
#if HSCRIPT_ALLOWED
import hscript.Expr;
import rulescript.types.ScriptedTypeUtil;
import haxe.extern.EitherType;
import hscript.Expr;
import rulescript.interps.RuleScriptInterp;
import rulescript.parsers.HxParser;
import rulescript.parsers.Parser;
import rulescript.types.ScriptedTypeUtil;

/**
 * Modified `haxe.PosInfos` type.	
 */
typedef HScriptInfos =
{
	/**
	 * Extend `haxe.PosInfos`.
	 */
	> haxe.PosInfos,

	/**
	 * The function name. (optional)
	 */
	@:optional var funcName:String;

	/**
	 * Show the line. (optional)
	 */
	@:optional var showLine:Null<Bool>;

	#if LUA_ALLOWED
	/**
	 * Has the HSCRIPT instance been created by lua.
	 */
	@:optional var isLua:Null<Bool>;
	#end
}

class HScript extends rulescript.RuleScript implements IScript implements IHScript
{
	/**
	 * All executed instances of `HSCRIPT`.	
	 */
	public static var instances:Map<String, HScript> = [];

	/**
	 * The script's file path.	
	 */
	public var filePath:String;

	/**
	 * The scripts mod folder.
	 */
	public var modFolder:String;

	/**
	 * Scripts return value.	
	 */
	public var returnValue:Dynamic;

	/**
	 * The script origin.	
	 */
	public var origin:String;

	/**
	 * The function which executes the code given.
	 */
	@:dox(show) override function execute(code:EitherType<String, Expr>):Dynamic
	{
		final exec = super.execute(code);
		instances.set(this.scriptName, this);
		return exec;
	}

	override public function setParent(parent:Dynamic)
	{
		final _interp:RuleScriptInterpreter = Std.isOfType(interp, RuleScriptInterpreter) ? cast interp : null;
		if (_interp == null)
			return; // bruh,,, i fucking hate types 🥺🙏
		_interp.superInstance = parent;
		return;
	}

	/**
	 * HScript's new constructor.
	 *
	 * @param parent The scripts parent. (optional)
	 * @param file The script file. (optional)
	 * @param varsToBring Variables to bring. (optional)
	 * @param manualRun If the script should manually run. (optional)
	 */
	@:dox(show) override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false):Void
	{
		file ??= '';
		filePath = file;

		if (filePath != null && filePath.length > 0)
		{
			this.origin = filePath;
			#if MODS_ALLOWED
			var myFolder:Array<String> = filePath.split('/');
			if (myFolder[0] + '/' == Paths.mods()
				&& (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}
		var scriptThing:String = file;
		var scriptName:String = null;
		if (parent == null && file != null)
		{
			var f:String = file.replace('\\', '/');
			if (f.contains('/') && !f.contains('\n'))
			{
				scriptThing = File.getContent(f);
				scriptName = f;
			}
		}
		#if LUA_ALLOWED
		if (scriptName == null && parent != null)
			scriptName = parent.scriptName;
		#end

		for (apply in Config.ALLOWED_CUSTOM_CLASSES)
		{
			var invalid:Bool = false;
			for (v in Config.DISALLOW_CUSTOM_CLASSES)
				if (apply.startsWith(v))
					invalid = true;
			if (!invalid)
			{
				var scriptedClassRef = HScriptUtils.fromMacro(apply);
				if (scriptedClassRef == null)
					continue;
				rulescript.types.Typedefs.register(apply, scriptedClassRef);
			}
		}
		rulescript.types.Typedefs.register('flixel.group.FlxGroup', FlxTypedGroup); // fix...

		ScriptedTypeUtil.resolveModule = HScriptUtils.resolveModule;
		RuleScript.resolveScript = ScriptedTypeUtil.resolveScript;

		final interp:RuleScriptInterpreter = new RuleScriptInterpreter();
		super(interp, new HxParser(), new Context());

		// set default vars n stuff

		getParser(HxParser).allowAll();
		errorHandler = HScriptUtils.onError;
		interp.superInstance = FlxG.state; // fallback :3

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
		{
			this.scriptName = parent.scriptName;
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end

		interp.scriptName = Path.withoutDirectory(scriptName);

		this.varsToBring = varsToBring;

		if (!manualRun)
		{
			try
				returnValue = cast tryExecute(scriptThing)
			catch (error:Exception)
			{
				returnValue = null;
				this.destroy();
				throw error;
			}
		}

		final duh:Map<String, Dynamic> = [
			'__script__' => this,
			'__scriptName__' => scriptName,

			'getModSetting' => (saveTag:String, ?modName:String = null) ->
			{
				if (modName == null)
				{
					if (this.modFolder == null)
					{
						HScriptedErrors.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!',
							untyped this.interp.posInfos());

						return null;
					}
					modName = this.modFolder;
				}
				return funkin.modding.lua.LuaUtils.getModSetting(saveTag, modName);
			},

			#if LUA_ALLOWED
			'createCallback' => (name:String, func:Dynamic, ?funk:FunkinLua = null) ->
			{
				if (funk == null)
					funk = parentLua;

				if (funk != null)
					funk.addLocalCallback(name, func);
				else
					HScriptedErrors.error('createCallback ($name): 3rd argument is null', untyped this.interp.posInfos());
			},
			#end

			'addHaxeLibrary' => (libName:String, ?libPackage:String = '') ->
			{
				try
				{
					var str:String = '';
					if (libPackage.length > 0)
						str = libPackage + '.';
					set(libName, Type.resolveClass(str + libName)); // don't add libs that dce literally FUCKED
				}
				catch (e:hscript.Expr.Error)
					HScriptedErrors.error(ScriptUtil.errorToString(e, false), untyped this.interp.posInfos());
			},

			'parentLua' => (#if LUA_ALLOWED parentLua #else null #end),
		];
		for (i => j in duh)
			variables.set(i, j);
	}

	// TODO make certain preset for stages, songs etc

	/**
	 * Set a import.	
	 */
	override public function set(name:String, param:Dynamic):Void
	{
		variables.set(name, param);
	}

	/**
	 * Get a variable...	
	 */
	override public function get(hehe):Null<Dynamic>
	{
		return variables.get(hehe);
	}

	/**
	 * Check if a variable exists.	
	 */
	public function exists(hehe):Bool
	{
		return variables.exists(hehe);
	}

	/**
	 * Safely call a function.	
	 */
	public function tryCall(funcToRun:String, ?args:Array<Dynamic>):Dynamic
	{
		try
			if (exists(funcToRun))
				return call(funcToRun, args)
		catch (_)
		{
		};
		return null;
	}

	override public function run(?args:Array<Dynamic>):Dynamic
	{
		try
		{
			tryCall('new', args);
			tryCall('onCreate');
			tryCall('create');

			for (i in instances)
				if (i != this && i.filePath != filePath)
				{
					instances.set(filePath, this);
					break;
				}

			// Logs.prefixedTrace('successfully initialized HScript interp on "$filePath"', 'Global Script', GREEN);
		}
		catch (error:hscript.Expr.Error)
		{
			final filePosInfos:HScriptInfos = cast {_fileName: filePath, showLine: false};
			HScriptedErrors.error(ScriptUtil.errorToString(error, false), filePosInfos);
			final castInstance = cast(HScript.instances.get(filePath), HScript);
			if (castInstance != null)
				castInstance.destroy();
		}

		return this;
	}

	/**
	 * Variables to bring.	
	 */
	var varsToBring(default, set):Any = null;

	@:dox(hide) function set_varsToBring(values:Any):Any
	{
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if (exists(key.trim()))
					variables.remove(key.trim());

		if (values != null)
		{
			for (key in Reflect.fields(values))
			{
				key = key.trim();
				set(key, Reflect.field(values, key));
			}
		}

		return varsToBring = values;
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		funk.addLocalCallback("runHaxeCode",
			function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic
			{
				initHaxeModuleCode(funk, codeToRun, varsToBring);
				if (funk.hscript != null)
				{
					final retVal = funk.hscript.call(funcToRun, funcArgs);
					if (retVal != null)
						return (retVal.returnValue == null
							|| LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
					else if (funk.hscript.returnValue != null)
						return funk.hscript.returnValue;
				}
				return null;
			});

		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null)
		{
			if (funk.hscript != null)
			{
				final retVal = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
				{
					return (retVal.returnValue == null
						|| LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
				}
			}
			else
			{
				var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
				if (funk.lastCalledFunction != '')
					pos.funcName = funk.lastCalledFunction;
				HScriptedErrors.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
			}
			return null;
		});

		// This function is unnecessary because import already exists in HScript as a native feature
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '')
		{
			var str:String = '';
			if (libPackage.length > 0)
				str = libPackage + '.';
			else if (libName == null)
				libName = '';

			var resolvedClass:Dynamic = Type.resolveClass(str + libName);
			resolvedClass ??= Type.resolveEnum(str + libName);
			if (funk.hscript == null)
				initHaxeModule(funk);

			var pos:HScriptInfos = cast(untyped funk.hscript.interp.posInfos());
			pos.showLine = false;
			if (funk.lastCalledFunction != '')
				pos.funcName = funk.lastCalledFunction;

			try
				if (resolvedClass != null)
					funk.hscript.set(libName, resolvedClass)
			catch (e:hscript.Expr.Error)
				HScriptedErrors.error(ScriptUtil.errorToString(e, false), pos);

			FunkinLua.lastCalledScript = funk;

			if (FunkinLua.getBool('luaDebugMode') && FunkinLua.getBool('luaDeprecatedWarnings'))
				HScriptedErrors.error("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
		});
	}
	#end

	override public function call(functionName:String, ?funcArgs:Array<Dynamic>)
	{
		if (functionName == null || interp == null)
			return null;

		if (!exists(functionName))
		{
			HScriptedErrors.error('No function named: $functionName', untyped this.interp.posInfos());
			return null;
		}

		try
		{
			var func:Dynamic = variables.get(functionName); // function signature
			final ret = Reflect.callMethod(null, func, funcArgs ?? []);
			return {funName: functionName, signature: func, returnValue: ret};
		}
		catch (e:hscript.Expr.Error)
		{
			var pos:HScriptInfos = cast(untyped this.interp.posInfos()); // ughhh i fucking hate untyped shitz
			pos.funcName = functionName;
			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '')
					pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			HScriptedErrors.error(ScriptUtil.errorToString(e, false), pos);
		}
		return null;
	}

	override public function stop():Void
	{
		destroy();
	}

	override public function destroy():Void
	{
		origin = null;
		instances.remove(filePath);
		#if LUA_ALLOWED parentLua = null; #end
	}

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;

	public static function initHaxeModule(parent:FunkinLua):Void
	{
		if (parent.hscript == null)
		{
			Logs.trace('Initializing haxe interp for {${parent.scriptName}}', RED);
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null):Void
	{
		var hs:HScript = try parent.hscript catch (e) null;

		if (hs == null)
		{
			Logs.trace('Initializing haxe interp for {${parent.scriptName}}', RED);
			try
				parent.hscript = new HScript(parent, code, varsToBring) // reg function maybe...
			catch (e:hscript.Expr.Error)
			{
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if (parent.lastCalledFunction != '')
					pos.funcName = parent.lastCalledFunction;
				HScriptedErrors.error(ScriptUtil.errorToString(e, false), pos);
				parent.hscript = null;
			}
		}
		else
		{
			try
			{
				hs.varsToBring = varsToBring;
				var ret:Dynamic = hs.tryExecute(code); // was execute but eh...
				hs.returnValue = ret;
			}
			catch (e:hscript.Expr.Error)
			{
				var pos:HScriptInfos = cast(untyped hs.interp.posInfos());
				pos.isLua = true;
				if (parent.lastCalledFunction != '')
					pos.funcName = parent.lastCalledFunction;
				HScriptedErrors.error(ScriptUtil.errorToString(e, false), pos);
				hs.returnValue = null;
			}
		}
	}
	#end
}
#else
class HScript
{
	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua):Void
	{
		function debug(txt:String):Dynamic
		{
			PlayState.instance.addTextToDebug(txt, FlxColor.RED);
			return null;
		}

		funk.addLocalCallback("runHaxeCode",
			(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null,
					?funcArgs:Array<Dynamic> = null) -> return debug('HScript is not supported on this platform!'));
		funk.addLocalCallback("runHaxeFunction",
			(funcToRun:String, ?funcArgs:Array<Dynamic> = null) -> return debug('HScript is not supported on this platform!'));
		funk.addLocalCallback("addHaxeLibrary", (libName:String, ?libPackage:String = '') -> return debug('HScript is not supported on this platform!'));
	}
	#end
}
#end
