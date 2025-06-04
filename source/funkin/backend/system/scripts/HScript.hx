package funkin.backend.system.scripts;

import hscript.Expr;
import rulescript.scriptedClass.RuleScriptedClass;
import rulescript.types.Typedefs;
import rulescript.scriptedClass.RuleScriptedClass.ScriptedClass;
import hscript.Expr.ClassDecl;
import hscript.Expr.ModuleDecl;
import rulescript.scriptedClass.RuleScriptedClass.Access;
import funkin.game.states.substates.CustomSubstate;
import flixel.FlxBasic;
import hscript.Printer;
import rulescript.*;
import rulescript.parsers.*;
import flixel.addons.display.FlxStarField;
import rulescript.scriptedClass.RuleScriptedClassUtil;
import rulescript.types.ScriptedTypeUtil;

#if LUA_ALLOWED import funkin.backend.system.scripts.FunkinLua; #end

#if HSCRIPT_ALLOWED
typedef HScriptInfos =
{
	> haxe.PosInfos,
	var ?funcName:String;
	var ?showLine:Null<Bool>;
	#if LUA_ALLOWED
	var ?isLua:Null<Bool>;
	#end
}
class HScript extends RuleScript implements IScript
{
	public static var instances:Map<String, HScript> = [];

	public var filePath:String;
	public var modFolder:String;
	public var returnValue:Dynamic;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;

	public static function initHaxeModule(parent:FunkinLua) : Void
	{
		if (parent.hscript == null)
		{
			Logs.trace('Initializing haxe interp for {${parent.scriptName}}', RED);
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null) : Void
	{
		var hs:HScript = try parent.hscript catch (e) null;

		if (hs == null)
		{
			Logs.trace('Initializing haxe interp for {${parent.scriptName}}', RED);
			try
				parent.hscript = new HScript(parent, code, varsToBring)// reg function maybe...
			catch (e:hscript.Expr.Error)
			{
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if (parent.lastCalledFunction != '')
					pos.funcName = parent.lastCalledFunction;
				ScriptedErrors.error(ScriptedErrors.errorToString(e, false), pos);
				parent.hscript = null;
			}
		}
		else
		{
			try
			{
				hs.varsToBring = varsToBring;
				// hs.parse(true);
				var ret:Dynamic = hs.tryExecute(code);// was execute but eh...
				// hs.returnValue = ret;
			}
			catch (e:hscript.Expr.Error)
			{
				var pos:HScriptInfos = null; cast (untyped hs.interp.posInfos());
				pos.isLua = true;
				if (parent.lastCalledFunction != '')
					pos.funcName = parent.lastCalledFunction;
				ScriptedErrors.error(ScriptedErrors.errorToString(e, false), pos); 
				hs.returnValue = null;
			}
		}
	}
	#end

	override function execute(code:EitherType<String, Expr>):Dynamic {
		final hehee = super.execute(code);
		instances.set(this.scriptName, this);
		return hehee;
	}

	public var origin:String;

	override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false)
	{
		if (file == null)
			file = '';

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
		 	var invalid : Bool = false;
		 	for (v in Config.DISALLOW_CUSTOM_CLASSES)
		 		if (apply.startsWith(v))
		 			invalid = true;
		 	if (!invalid){
				var scriptedClassRef = HScriptUtils.getScriptedClass(apply);
				if(scriptedClassRef == null) continue;
		 		Typedefs.register(apply, scriptedClassRef);
			}
		 }

		ScriptedTypeUtil.resolveModule = HScriptUtils.resolveModule;
		RuleScript.resolveScript = ScriptedTypeUtil.resolveScript;

		final interp:RuleScriptInterpreter = new RuleScriptInterpreter();
		super(interp, new HxParser());
		getParser(HxParser).allowAll();
		errorHandler = HScriptUtils.onError;
		interp.parent = FlxG.state?.subState != null ? FlxG.state.subState : FlxG.state;// scripted substates fix
	
		if(variables.exists('main'))
			variables.get('main')();

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
		{
			this.scriptName = parent.scriptName;
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end

		for (i => j in defaultVariables)// set default vars n stuff
			set(i, j);

		this.varsToBring = varsToBring;

		if (!manualRun)
		{
			try
				returnValue = cast tryExecute(scriptThing)
			catch (error)
			{
				returnValue = null;
				this.destroy();
				throw error;
			}
		}
	}

	function set(name:String, eee:Dynamic) : Void
		RuleScript.defaultImports.get('').set(name, eee);

	function get(hehe):Null<Dynamic>
		return variables.get(hehe);

	function exists(hehe) : Bool
		return variables.exists(hehe);

	public function safeCall(funcToRun:String, ?args:Array<Dynamic>)
	{
		if (exists(funcToRun))
			return call(funcToRun, args);
		return null;
	}

	public function run(?args:Array<Dynamic>, ?customGroupMap:String):HScript
	{
		try
		{
			safeCall('new', args);
			safeCall('onCreate');
			safeCall('create');
			// GlobalScript.instance.hscriptInstances.push(this);

			final scriptGroup = customGroupMap == null ? Main.stateName : customGroupMap;
			GlobalScript.instance.hscriptInstances.exists(scriptGroup) ? GlobalScript.instance.hscriptInstances.get(scriptGroup)
				.push(this) : GlobalScript.instance.hscriptInstances.set(scriptGroup, [this]);

			Logs.prefixedTrace('successfully initialized HScript interp on "$filePath"', 'Global Script', GREEN);
		}
		catch (error:hscript.Expr.Error)
		{
			final filePosInfos:HScriptInfos = cast {_fileName: filePath, showLine: false};
			ScriptedErrors.error(ScriptedErrors.errorToString(error, false), filePosInfos); 
			final castInstance = cast(HScript.instances.get(filePath), HScript);
			if (castInstance != null)
				castInstance.destroy();
		}

		return this;
	}

	var varsToBring(default, set):Any = null;
	@:dox(hide) @:noCompletion function set_varsToBring(values:Any) : Any
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

	public var defaultVariables(get, never):Map<String, Dynamic>;
	function get_defaultVariables():Map<String, Dynamic>
	{
		#if SOFTCODED_STATES 
		function closeInstanceSubstate():Void // for custom substates ;3
			if (FlxG.state != null && FlxG.state.subState != null)
				FlxG.state.subState.close();
		#end

		return [
		// Haxe Stuffz
		'Type' => Type,
		'Main' => funkin.game.Main,
		'StringTools' => StringTools,
		#if sys 'File' => File, 'FileSystem' => FileSystem, #end
		
		// Flixel-Specific Stuff
		'FlxG' => flixel.FlxG,
		'FlxMath' => flixel.math.FlxMath,
		'FlxSprite' => flixel.FlxSprite,
		'FlxText' => flixel.text.FlxText,
		'FlxDestroyUtil' => flixel.util.FlxDestroyUtil,
		'FlxTimer' => flixel.util.FlxTimer,
		'FlxTween' => flixel.tweens.FlxTween,
		'FlxEase' => flixel.tweens.FlxEase,
		#if (!flash && sys) 'FlxRuntimeShader' => flixel.addons.display.FlxRuntimeShader, #end

		// OpenFL-Specific Stuff
		'ShaderFilter' =>  openfl.filters.ShaderFilter,

		// Cameras
		'FlxCamera' => flixel.FlxCamera,
		'PsychCamera' => CustomCamera,
		'CustomCamera' => CustomCamera,
		'AstroCamera' => CustomCamera,

		// States
		'FlxState' => FlxState,
		'MusicBeatState' => MusicBeatState,
		'MusicBeatSubstate' => MusicBeatSubstate,
		'TitleState' => TitleState,

		// Game-specific
		'Countdown' => funkin.backend.base.BaseStage.Countdown,
		'PlayState' => PlayState,
		'Paths' => Paths,
		'Conductor' => Conductor,
		'ClientPrefs' => ClientPrefs,
		'WindowUtil' => funkin.backend.utils.native.WindowUtil,
		'Character' => Character,
		'Alphabet' => Alphabet,
		'Note' => Note,
		'Logs' => Logs,
		'CustomSubstate' => CustomSubstate,
		'FlxAnimate' => FlxAnimate,
		#if ACHIEVEMENTS_ALLOWED 'Achievements' => Achievements, #end
		#if SOFTCODED_STATES 'close' => closeInstanceSubstate, 'closeSub' => closeInstanceSubstate, #end

		// Functions & Variables
		'setVar' => (name:String, value:Dynamic) -> {
			MusicBeatState.getVariables().set(name, value);
			return value;
		},
		'getVar' => (name:String) -> {
			var result:Dynamic = null;
			if (MusicBeatState.getVariables().exists(name))
				result = MusicBeatState.getVariables().get(name);
			return result;
		},
		'removeVar' => (name:String) -> {
			if (MusicBeatState.getVariables().exists(name))
			{
				MusicBeatState.getVariables().remove(name);
				return true;
			}
			return false;
		},
		'debugPrint' =>(text:String, ?color:FlxColor = null) -> {
			if (color == null)
				color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		},
		'getModSetting' => (saveTag:String, ?modName:String = null) -> {
			if (modName == null)
			{
				if (this.modFolder == null)
				{
					ScriptedErrors.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', untyped this.interp.posInfos()); 
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		},

		// Keyboard & Gamepads
		'keyboardJustPressed' => (name:String) -> return Reflect.getProperty(FlxG.keys.justPressed, name),
		'keyboardPressed' => (name:String) -> return Reflect.getProperty(FlxG.keys.pressed, name),
		'keyboardReleased' => (name:String) -> return Reflect.getProperty(FlxG.keys.justReleased, name),

		'anyGamepadJustPressed' => (name:String) -> return FlxG.gamepads.anyJustPressed(name),
		'anyGamepadPressed' => (name:String) -> FlxG.gamepads.anyPressed(name),
		'anyGamepadReleased' => (name:String) -> return FlxG.gamepads.anyJustReleased(name),

		'gamepadAnalogX' => (id:Int, ?leftStick:Bool = true) -> {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		},
		'gamepadAnalogY' => (id:Int, ?leftStick:Bool = true) -> {
			final controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;
			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		},

		'gamepadJustPressed' => (id:Int, name:String) -> {// find a better way :(
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		},
		'gamepadPressed' => (id:Int, name:String) -> {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		},
		'gamepadReleased' => (id:Int, name:String) -> {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		},
		'keyJustPressed' => (name:String = '') -> {
			name = name.toLowerCase();
			switch (name)
			{
				case 'left':
					return Controls.instance.NOTE_LEFT_P;
				case 'down':
					return Controls.instance.NOTE_DOWN_P;
				case 'up':
					return Controls.instance.NOTE_UP_P;
				case 'right':
					return Controls.instance.NOTE_RIGHT_P;
				default:
					return Controls.instance.justPressed(name);
			}
			return false;
		},

		'keyPressed' => (name:String = '') -> {
			name = name.toLowerCase();
			switch (name)
			{
				case 'left':
					return Controls.instance.NOTE_LEFT;
				case 'down':
					return Controls.instance.NOTE_DOWN;
				case 'up':
					return Controls.instance.NOTE_UP;
				case 'right':
					return Controls.instance.NOTE_RIGHT;
				default:
					return Controls.instance.pressed(name);
			}
			return false;
		},
		'keyReleased' => (name:String = '') -> {
			name = name.toLowerCase();

			switch (name)
			{
				case 'left':
					return Controls.instance.NOTE_LEFT_R;
				case 'down':
					return Controls.instance.NOTE_DOWN_R;
				case 'up':
					return Controls.instance.NOTE_UP_R;
				case 'right':
					return Controls.instance.NOTE_RIGHT_R;
				default:
					return Controls.instance.justReleased(name);
			}

			return false;
		},

		#if LUA_ALLOWED
		// For adding your own callbacks
		// not very tested but should work
		'createGlobalCallback' => (name:String, func:Dynamic) -> {
			for (script in GlobalScript.instance.luaInstances)
				if (script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);

			FunkinLua.customFunctions.set(name, func);
		},

		// this one was tested
		'createCallback' => (name:String, func:Dynamic, ?funk:FunkinLua = null) ->
		{
			if (funk == null)
				funk = parentLua;

			if (funk != null)
				funk.addLocalCallback(name, func);
			else
				ScriptedErrors.error('createCallback ($name): 3rd argument is null', untyped this.interp.posInfos());
		},
		#end

		'addHxObject' => (obj:FlxObject, front:Bool = false) -> { // stolen from FunkinLua
			if (PlayState.instance != null) { FlxG.log.warn('HScript: {addHxObject} isn\'t allowed in current state'); return null; }

			if (obj == null) return false;

			var instance = LuaUtils.getTargetInstance();
			if (front) instance.add(obj);
			else
			{
				(PlayState.instance == null || !PlayState.instance.isDead) ? 
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), obj) :
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
			}
			return true;
		},
		'addHaxeLibrary' =>(libName:String, ?libPackage:String = '') -> {
			try
			{
				var str:String = '';
				if (libPackage.length > 0)
					str = libPackage + '.';
				set(libName, Type.resolveClass(str + libName));// don't add libs that dce literally FUCKED
			} catch (e:hscript.Expr.Error) { ScriptedErrors.error(ScriptedErrors.errorToString(e, false), untyped this.interp.posInfos()); }
		},

		'parentLua' => (#if LUA_ALLOWED parentLua #else null #end),

		'this' => this,
		//'game' => FlxG.state, now handled by interp
		'controls' => Controls.instance,

		'buildTarget' => LuaUtils.getBuildTarget(),
		'customSubstate' => CustomSubstate.instance,
		'customSubstateName' => CustomSubstate.name,

		'Function_Stop' => Function_Stop,
		'Function_Continue' => Function_Continue,
		'Function_StopLua' => Function_StopLua, // doesnt do much cuz HScript has a lower priority than Lua
		'Function_StopHScript' => Function_StopHScript,
		'Function_StopAll' => Function_StopAll,
	];
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
				ScriptedErrors.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
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

			var c:Dynamic = Type.resolveClass(str + libName);
			if (c == null)
				c = Type.resolveEnum(str + libName);

			if (funk.hscript == null)
				initHaxeModule(funk);

			var pos:HScriptInfos = cast (untyped funk.hscript.interp.posInfos());
			pos.showLine = false;
			if (funk.lastCalledFunction != '')
				pos.funcName = funk.lastCalledFunction;

			try
			{
				if (c != null)
					funk.hscript.set(libName, c);
			}
			catch (e:hscript.Expr.Error)
			{
				ScriptedErrors.error(ScriptedErrors.errorToString(e, false), pos);
			} 

			FunkinLua.lastCalledScript = funk;

			if (FunkinLua.getBool('luaDebugMode') && FunkinLua.getBool('luaDeprecatedWarnings'))
				ScriptedErrors.error("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
		});
	}
	#end

	public function call(functionName:String, ?args:Array<Dynamic>)
	{
		if (functionName == null || interp == null)
			return null;

		if (!exists(functionName))
		{
			ScriptedErrors.error('No function named: $functionName', untyped this.interp.posInfos());
			return null;
		}

		try
		{
			var func:Dynamic = variables.get(functionName); // function signature
			final ret = Reflect.callMethod(null, func, args ?? []);
			return {funName: functionName, signature: func, returnValue: ret};
		}
		catch (e:hscript.Expr.Error)
		{
			var pos:HScriptInfos = cast (untyped this.interp.posInfos()); // ughhh i fucking hate untyped shitz
			pos.funcName = functionName;
			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '')
					pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			ScriptedErrors.error(ScriptedErrors.errorToString(e, false), pos);
		}
		return null;
	}

	public function destroy() : Void
	{
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end
		//super.destroy();
	}
}
#else
class HScript// why not #elif (LUA_ALLOWED) or smth
{
	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) : Void
	{
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic
		{
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null)
		{
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '')
		{
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
	}
	#end
}
#end