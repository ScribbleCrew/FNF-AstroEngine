package funkin.backend.system.scripts;

import funkin.game.states.substates.CustomSubstate;
import flixel.FlxBasic;

#if LUA_ALLOWED
import funkin.backend.system.scripts.FunkinLua;
#end
import funkin.backend.system.scripts.custom.*;

#if HSCRIPT_ALLOWED
typedef HScriptInfos = {
	> haxe.PosInfos,
	var ?funcName:String;
	var ?showLine:Null<Bool>;
	#if LUA_ALLOWED
	var ?isLua:Null<Bool>;
	#end
}

class HScript extends Iris implements IScript
{
	public var filePath:String;
	public var modFolder:String;
	public var returnValue:Dynamic;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;
	public static function initHaxeModule(parent:FunkinLua)
	{
		if(parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null)
	{
		var hs:HScript = try parent.hscript catch (e) null;
		if(hs == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			try {
				parent.hscript = new HScript(parent, code, varsToBring);
			}
			catch(e:IrisError) {
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if(parent.lastCalledFunction != '') pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				parent.hscript = null;
			}
		}
		else
		{
			try
			{
				hs.scriptCode = code;
				hs.varsToBring = varsToBring;
				hs.parse(true);
				var ret:Dynamic = hs.execute();
				hs.returnValue = ret;
			}
			catch(e:IrisError)
			{
				var pos:HScriptInfos = cast hs.interp.posInfos();
				pos.isLua = true;
				if(parent.lastCalledFunction != '') pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				hs.returnValue = null;
			}
		}
	}
	#end

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
			if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}
		var scriptThing:String = file;
		var scriptName:String = null;
		if(parent == null && file != null)
		{
			var f:String = file.replace('\\', '/');
			if(f.contains('/') && !f.contains('\n')) {
				scriptThing = File.getContent(f);
				scriptName = f;
			}
		}
		#if LUA_ALLOWED
		if (scriptName == null && parent != null)
			scriptName = parent.scriptName;
		#end
		super(scriptThing, new IrisConfig(scriptName, false, false));
		var customInterp:CustomInterp = new CustomInterp();
		customInterp.parentInstance = FlxG.state;
		customInterp.showPosOnLog = false;
		this.interp = customInterp;
		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
		{
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end
		preset();
		this.varsToBring = varsToBring;
		if (!manualRun) {
			try {
				var ret:Dynamic = execute();
				returnValue = ret;
			} catch(e:IrisError) {
				returnValue = null;
				this.destroy();
				throw e;
			}
		}
	}
	public function safeCall(funcToRun:String, ?args:Array<Dynamic>):IrisCall
	{
		if (exists(funcToRun))
			return call(funcToRun, args);
		return null;
	}

	public function run(?args:Array<Dynamic>) : HScript{
		try
		{		
			safeCall('new', args);
			safeCall('onCreate');
			safeCall('create');
			GlobalScript.instance.hscriptInstances.push(this);

			Logs.prefixedTrace('successfully initialized HScript interp on "$filePath"', 'Global Script', GREEN);
		}
		catch (error:IrisError)
		{
			final filePosInfos:HScriptInfos = cast {_fileName: filePath, showLine: false};
			Iris.error(Printer.errorToString(error, false), filePosInfos);

			final castInstance = cast(Iris.instances.get(filePath), HScript);
			if (castInstance != null)
				castInstance.destroy();
		}

		return this;
	}

	var varsToBring(default, set):Any = null;
	
	override function preset() {
		super.preset();

		// Some very commonly used classes
		set('Type', Type);
		set('Main', funkin.game.Main);
		#if sys
		set('File', File);
		set('FileSystem', FileSystem);
		#end
		set('FlxG', flixel.FlxG);
		set('FlxTextAlign', CustomFlxTextAlign);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxDestroyUtil',flixel.util.FlxDestroyUtil);

		// Cameras
		set('FlxCamera', flixel.FlxCamera);
		set('PsychCamera', CustomCamera);//more psych support.
		set('CustomCamera', CustomCamera);
		set('AstroCamera', CustomCamera);

		// States
		set('FlxState', FlxState);
		set('MusicBeatState', MusicBeatState);
		set('MusicBeatSubstate', MusicBeatSubstate);

		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxAxes', CustomFlxAxes);
		set('FlxColor', CustomFlxColor);
		set('Countdown', funkin.backend.base.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		set('WindowUtil', funkin.backend.utils.native.WindowUtil);

		#if ACHIEVEMENTS_ALLOWED
		set('Achievements', Achievements);
		#end
		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', Note);
		set('Logs', Logs);
		set('CustomSubstate', CustomSubstate);
		#if (!flash && sys) set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader); #end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);
		#if flxanimate set('FlxAnimate', FlxAnimate); #end

		#if SOFTCODED_STATES
		// for custom substates ;3
		function closeInstanceSubstate() : Void {
			if(FlxG.state?.subState!=null)
				FlxG.state.subState.close();
		}

		set('close', closeInstanceSubstate);
		set('closeSub', closeInstanceSubstate);
		#end

		// Functions & Variables
		set('setVar', function(name:String, value:Dynamic) {
			MusicBeatState.getVariables().set(name, value);
			return value;
		});
		set('getVar', function(name:String) {
			var result:Dynamic = null;
			if(MusicBeatState.getVariables().exists(name)) result = MusicBeatState.getVariables().get(name);
			return result;
		});
		set('removeVar', function(name:String)
		{
			if(MusicBeatState.getVariables().exists(name))
			{
				MusicBeatState.getVariables().remove(name);
				return true;
			}
			return false;
		});
		set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});
		set('getModSetting', function(saveTag:String, ?modName:String = null) {
			if(modName == null)
			{
				if(this.modFolder == null)
				{
					Iris.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', this.interp.posInfos());
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});

		// Keyboard & Gamepads
		set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
		set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
		set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

		set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadJustPressed', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		set('gamepadPressed', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		set('gamepadReleased', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		set('keyJustPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT_P;
				case 'down': return Controls.instance.NOTE_DOWN_P;
				case 'up': return Controls.instance.NOTE_UP_P;
				case 'right': return Controls.instance.NOTE_RIGHT_P;
				default: return Controls.instance.justPressed(name);
			}
			return false;
		});
		set('keyPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT;
				case 'down': return Controls.instance.NOTE_DOWN;
				case 'up': return Controls.instance.NOTE_UP;
				case 'right': return Controls.instance.NOTE_RIGHT;
				default: return Controls.instance.pressed(name);
			}
			return false;
		});
		set('keyReleased', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return Controls.instance.NOTE_LEFT_R;
				case 'down': return Controls.instance.NOTE_DOWN_R;
				case 'up': return Controls.instance.NOTE_UP_R;
				case 'right': return Controls.instance.NOTE_RIGHT_R;
				default: return Controls.instance.justReleased(name);
			}
			return false;
		});

		// For adding your own callbacks
		// not very tested but should work
		#if LUA_ALLOWED
		set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			for (script in GlobalScript.instance.luaInstances)
				if(script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);

			FunkinLua.customFunctions.set(name, func);
		});

		// this one was tested
		set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if(funk == null) funk = parentLua;
			
			if(funk != null) funk.addLocalCallback(name, func);
			else Iris.error('createCallback ($name): 3rd argument is null', this.interp.posInfos());
		});
		#end

		set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:IrisError) {
				Iris.error(Printer.errorToString(e, false), this.interp.posInfos());
			}
		});
		#if LUA_ALLOWED
		set('parentLua', parentLua);
		#else
		set('parentLua', null);
		#end
		set('this', this);
		set('game', FlxG.state);
		set('controls', Controls.instance);

		set('buildTarget', LuaUtils.getBuildTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('Function_StopLua', Function_StopLua); //doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', Function_StopHScript);
		set('Function_StopAll', Function_StopAll);
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) {
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			initHaxeModuleCode(funk, codeToRun, varsToBring);
			if (funk.hscript != null)
			{
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
				else if (funk.hscript.returnValue != null)
					return funk.hscript.returnValue;
			}
			return null;
		});
		
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			if (funk.hscript != null)
			{
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
				{
					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
				}
			}
			else
			{
				var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
				if (funk.lastCalledFunction != '') pos.funcName = funk.lastCalledFunction;
				Iris.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
			}
			return null;
		});
		// This function is unnecessary because import already exists in HScript as a native feature
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
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

			var pos:HScriptInfos = cast funk.hscript.interp.posInfos();
			pos.showLine = false;
			if (funk.lastCalledFunction != '')
				 pos.funcName = funk.lastCalledFunction;

			try {
				if (c != null)
					funk.hscript.set(libName, c);
			}
			catch (e:IrisError) {
				Iris.error(Printer.errorToString(e, false), pos);
			}
			FunkinLua.lastCalledScript = funk;
			if (FunkinLua.getBool('luaDebugMode') && FunkinLua.getBool('luaDeprecatedWarnings'))
				Iris.warn("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
		});
	}
	#end

	override function call(functionName:String, ?args:Array<Dynamic>):IrisCall {
		if (functionName == null || interp == null) return null;

		if (!exists(functionName)) {
			Iris.error('No function named: $functionName', this.interp.posInfos());
			return null;
		}

		try {
			var func:Dynamic = interp.variables.get(functionName); // function signature
			final ret = Reflect.callMethod(null, func, args ?? []);
			return {funName: functionName, signature: func, returnValue: ret};
		}
		catch(e:IrisError) {
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.funcName = functionName;
			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '') pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			Iris.error(Printer.errorToString(e, false), pos);
		}
		return null;
	}

	override public function destroy()
	{
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end
		super.destroy();
	}

	function set_varsToBring(values:Any) {
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if (exists(key.trim()))
					interp.variables.remove(key.trim());

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
}
#else
class HScript
{
	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) {
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
	}
	#end
}
#end