package funkin.backend.funkinLua;

import funkin.backend.funkinLua.luaStuff.ModchartText;
import funkin.backend.funkinLua.luaStuff.ModchartSprite;
import funkin.game.states.LoadingState;
import openfl.display.BitmapData;
#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end
import funkin.game.states.substates.*;
import funkin.backend.utils.ClientPrefs;
import funkin.game.objects.characters.Character;
import funkin.backend.Song;
import funkin.backend.Highscore;
import funkin.game.states.PlayState;
import funkin.backend.Conductor;
import funkin.game.states.substates.GameOverSubstate;
import flixel.FlxG;
import funkin.game.states.substates.PauseSubState;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import funkin.backend.data.*;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxAssets.FlxShader;
#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Type.ValueType;
import funkin.backend.utils.Controls;
import funkin.game.objects.DialogueBoxPsych;
import funkin.backend.system.MusicBeatSubstate;
import funkin.backend.system.MusicBeatState;
#if desktop
import funkin.backend.client.Discord;
#end
import funkin.backend.funkinLua.functions.*;
import funkin.backend.funkinLua.LuaUtils;
#if HSCRIPT_ALLOWED
import funkin.backend.funkinLua.HScript;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

class FunkinLua
{
	// public var errorHandler:String->Void;
	#if LUA_ALLOWED
	public var lua:State = null;
	#end
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var closed:Bool = false;

	var game:PlayState = PlayState.instance;

	#if HSCRIPT_ALLOWED
	public var hscript:HScript = null;
	#end

	public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static var customFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(script:String)
	{
		#if LUA_ALLOWED
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		var variables = MusicBeatState.getVariables();

		try
		{
			var result:Dynamic = LuaL.dofile(lua, script);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0)
			{
				trace('Error on lua script! ' + resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('Error loading lua script: "$script"\n' + resultStr, true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
		}
		catch (e:Dynamic)
		{
			trace(e);
			return;
		}
		scriptName = script;
		#if HSCRIPT_ALLOWED initHaxeModule();#end

		trace('Loaded Lua File:' + script);

		// Lua shit
		set('Function_StopLua', LuaUtils.Function_StopLua);
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);
		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('version', EngineData.engineData.coreVersion.trim());

		// Song/Week shit
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('songPath', Paths.formatToSongPath(PlayState.SONG.song));
		set('startedCountdown', false);
		set('curStage', PlayState.SONG.stage);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);

		set('difficultyName', Difficulty.getString());
		set('difficultyPath', Paths.formatToSongPath(Difficulty.getString()));
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);
		set('hasVocals', PlayState.SONG.needsVoices);

		// Camera poo
		set('cameraX', 0);
		set('cameraY', 0);

		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);
		// PlayState-only variables
		if (game != null)
		{
			set('curSection', 0);
			set('curBeat', 0);
			set('curStep', 0);
			set('curDecBeat', 0);
			set('curDecStep', 0);

			set('score', 0);
			set('misses', 0);
			set('hits', 0);
			set('combo', 0);

			set('rating', 0);
			set('ratingName', '');
			set('ratingFC', '');

			set('inGameOver', false);
			set('mustHitSection', false);
			set('altAnim', false);
			set('gfSection', false);

			set('healthGainMult', game.healthGain);
			set('healthLossMult', game.healthLoss);

			#if FLX_PITCH
			set('playbackRate', game.playbackRate);
			#else
			set('playbackRate', 1);
			#end

			set('instakillOnMiss', game.instakillOnMiss);
			set('botPlay', game.cpuControlled);
			set('practice', game.practiceMode);

			for (i in 0...4)
			{
				set('defaultPlayerStrumX' + i, 0);
				set('defaultPlayerStrumY' + i, 0);
				set('defaultOpponentStrumX' + i, 0);
				set('defaultOpponentStrumY' + i, 0);
			}

			// Default character data
			set('defaultBoyfriendX', game.BF_X);
			set('defaultBoyfriendY', game.BF_Y);
			set('defaultOpponentX', game.DAD_X);
			set('defaultOpponentY', game.DAD_Y);
			set('defaultGirlfriendX', game.GF_X);
			set('defaultGirlfriendY', game.GF_Y);

			set('boyfriendName', PlayState.SONG.player1);
			set('dadName', PlayState.SONG.player2);
			set('gfName', PlayState.SONG.gfVersion);
		}

		// Some settings, no jokes
		set('downscroll', ClientPrefs.data.downScroll);
		set('middlescroll', ClientPrefs.data.middleScroll);
		set('framerate', ClientPrefs.data.framerate);
		set('ghostTapping', ClientPrefs.data.ghostTapping);
		set('hideHud', ClientPrefs.data.hideFullHUD);
		set('timeBarType', ClientPrefs.data.timeBarType);
		set('scoreZoom', ClientPrefs.data.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.data.camZooms);
		set('flashingLights', ClientPrefs.data.flashing);
		set('noteOffset', ClientPrefs.data.noteOffset);
		set('healthBarAlpha', ClientPrefs.data.healthBarAlpha);
		set('noResetButton', ClientPrefs.data.noReset);
		set('lowQuality', ClientPrefs.data.lowQuality);
		set('hideFullHUD', ClientPrefs.data.hideFullHUD);
		set('shadersEnabled', ClientPrefs.data.shaders);
		set('scriptName', scriptName);
		set('currentModDirectory', Mods.currentModDirectory);
		set('scoreBarType', ClientPrefs.data.scoreBarType);
		#if windows set('darkMode', WindowUtil.darkMode); #end

		set('buildTarget', LuaUtils.getBuildTarget());

		// custom substate
		Lua_helper.add_callback(lua, "openCustomSubstate", function(name:String, pauseGame:Bool = false)
		{
			try
			{
				if (pauseGame)
				{
					game.persistentUpdate = false;
					game.persistentDraw = true;
					game.paused = true;
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						game.vocals.pause();
					}
				}
				game.openSubState(new CustomSubstate(name));
			}
			catch (e)
				trace(e);
		});

		Lua_helper.add_callback(lua, "closeCustomSubstate", function()
		{
			if (CustomSubstate.instance != null)
			{
				game.closeSubState();
				CustomSubstate.instance = null;
				return true;
			}
			return false;
		});

		//
		Lua_helper.add_callback(lua, "getRunningScripts", function()
		{
			var runningScripts:Array<String> = [];
			for (script in game.luaArray)
				runningScripts.push(script.scriptName);

			return runningScripts;
		});

		addLocalCallback("setOnScripts", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null)
		{
			if (exclusions == null)
				exclusions = [];
			if (ignoreSelf && !exclusions.contains(scriptName))
				exclusions.push(scriptName);
			game.setOnScripts(varName, arg, exclusions);
		});
		addLocalCallback("setOnHScript", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null)
		{
			if (exclusions == null)
				exclusions = [];
			if (ignoreSelf && !exclusions.contains(scriptName))
				exclusions.push(scriptName);
			game.setOnHScript(varName, arg, exclusions);
		});
		addLocalCallback("setOnLuas", function(varName:String, arg:Null<Dynamic>, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
			if(varName == null) Lua.pushnil(lua);
			game.setOnLuas(varName, arg, exclusions);
		});
		addLocalCallback("callOnScripts",
			function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
					?excludeValues:Array<Dynamic> = null)
			{
				if (excludeScripts == null)
					excludeScripts = [];
				if (ignoreSelf && !excludeScripts.contains(scriptName))
					excludeScripts.push(scriptName);
				game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
				return true;
			});
		addLocalCallback("callOnLuas",
			function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
					?excludeValues:Array<Dynamic> = null)
			{
				if (excludeScripts == null)
					excludeScripts = [];
				if (ignoreSelf && !excludeScripts.contains(scriptName))
					excludeScripts.push(scriptName);
				game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
				return true;
			});
		addLocalCallback("callOnHScript",
			function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null,
					?excludeValues:Array<Dynamic> = null)
			{
				if (excludeScripts == null)
					excludeScripts = [];
				if (ignoreSelf && !excludeScripts.contains(scriptName))
					excludeScripts.push(scriptName);
				game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
				return true;
			});

		Lua_helper.add_callback(lua, "callScript", function(luaFile:String, funcName:String, ?args:Array<Dynamic> = null)
		{
			if (args == null)
			{
				args = [];
			}

			var foundScript:String = findScript(luaFile);
			if (foundScript != null)
				for (luaInstance in game.luaArray)
					if (luaInstance.scriptName == foundScript)
					{
						luaInstance.call(funcName, args);
						return;
					}
		});

		Lua_helper.add_callback(lua, "getGlobalFromScript", function(luaFile:String, global:String)
		{ // returns the global from a script
			var foundScript:String = findScript(luaFile);
			if (foundScript != null)
				for (luaInstance in game.luaArray)
					if (luaInstance.scriptName == foundScript)
					{
						Lua.getglobal(luaInstance.lua, global);
						if (Lua.isnumber(luaInstance.lua, -1))
							Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
						else if (Lua.isstring(luaInstance.lua, -1))
							Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
						else if (Lua.isboolean(luaInstance.lua, -1))
							Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
						else
							Lua.pushnil(lua);

						// TODO: table

						Lua.pop(luaInstance.lua, 1); // remove the global

						return;
					}
		});
		Lua_helper.add_callback(lua, "setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic)
		{ // returns the global from a script
			var foundScript:String = findScript(luaFile);
			if (foundScript != null)
				for (luaInstance in game.luaArray)
					if (luaInstance.scriptName == foundScript)
						luaInstance.set(global, val);
		});

		Lua_helper.add_callback(lua, "isRunning", function(luaFile:String)
		{
			var cervix = luaFile + ".lua";
			if (luaFile.endsWith(".lua"))
				cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if (FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if (FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else
			{
				cervix = Paths.getSharedPath(cervix);
				if (FileSystem.exists(cervix))
				{
					doPush = true;
				}
			}
			#else
			cervix = Paths.getSharedPath(cervix);
			if (Assets.exists(cervix))
			{
				doPush = true;
			}
			#end

			if (doPush)
			{
				for (luaInstance in game.luaArray)
				{
					if (luaInstance.scriptName == cervix)
						return true;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false)
		{ // would be dope asf.
			var cervix = luaFile + ".lua";
			if (luaFile.endsWith(".lua"))
				cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if (FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if (FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else
			{
				cervix = Paths.getSharedPath(cervix);
				if (FileSystem.exists(cervix))
				{
					doPush = true;
				}
			}
			#else
			cervix = Paths.getSharedPath(cervix);
			if (Assets.exists(cervix))
			{
				doPush = true;
			}
			#end

			if (doPush)
			{
				if (!ignoreAlreadyRunning)
				{
					for (luaInstance in game.luaArray)
					{
						if (luaInstance.scriptName == cervix)
						{
							luaTrace('addLuaScript: The script "' + cervix + '" is already running!');
							return;
						}
					}
				}
				game.luaArray.push(new FunkinLua(cervix));
				return;
			}
			luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false)
		{ // would be dope asf.
			var cervix = luaFile + ".lua";
			if (luaFile.endsWith(".lua"))
				cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if (FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if (FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else
			{
				cervix = Paths.getSharedPath(cervix);
				if (FileSystem.exists(cervix))
				{
					doPush = true;
				}
			}
			#else
			cervix = Paths.getSharedPath(cervix);
			if (Assets.exists(cervix))
			{
				doPush = true;
			}
			#end

			if (doPush)
			{
				if (!ignoreAlreadyRunning)
				{
					for (luaInstance in game.luaArray)
					{
						if (luaInstance.scriptName == cervix)
						{
							// luaTrace('The script "' + cervix + '" is already running!');

							game.luaArray.remove(luaInstance);
							return;
						}
					}
				}
				return;
			}
			luaTrace("removeLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});

		addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):IrisCall {
			#if HSCRIPT_ALLOWED
			HScript.initHaxeModuleCode(this, codeToRun, varsToBring);
			try
			{
				final retVal:IrisCall = hscript.executeCode(funcToRun, funcArgs);
				if (retVal != null)
				{
					return (retVal.methodVal == null || LuaUtils.isOfTypes(retVal.methodVal, [Bool, Int, Float, String, Array])) ? retVal.methodVal : null;
				}
			}
			catch(e:Dynamic)
			{
				FunkinLua.luaTrace('ERROR (${hscript.origin}: $funcToRun) - $e', false, false, FlxColor.RED);
			}

			#else
			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
			return null;
		});
		
		
		addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			#if HSCRIPT_ALLOWED
			try
			{
				final retVal:IrisCall = hscript.executeFunction(funcToRun, funcArgs);
				if (retVal != null)
				{
					return (retVal.methodVal == null || LuaUtils.isOfTypes(retVal.methodVal, [Bool, Int, Float, String, Array])) ? retVal.methodVal : null;
				}
			}
			catch(e:Dynamic)
			{
				FunkinLua.luaTrace('ERROR (${hscript.origin}: $funcToRun) - $e', false, false, FlxColor.RED);
			}
			return null;
			#else
			FunkinLua.luaTrace("runHaxeFunction: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			return null;
			#end
		});
		// This function is unnecessary because import already exists in HScript as a native feature
		addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			var str:String = '';
			if(libPackage.length > 0)
				str = libPackage + '.';
			else if(libName == null)
				libName = '';

			var c:Dynamic = Type.resolveClass(str + libName);
			if (c == null)
				c = Type.resolveEnum(str + libName);

			#if HSCRIPT_ALLOWED
			if (hscript != null)
			{
				try {
					if (c != null)
						hscript.set(libName, c);
				}
				catch (e:Dynamic) {
					FunkinLua.luaTrace(hscript.origin + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				}
			}
			#else
			FunkinLua.luaTrace("addHaxeLibrary: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "loadSong", function(?name:String = null, ?difficultyNum:Int = -1) {
			if(name == null || name.length < 1)
				name = Song.loadedSongName;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var poop = Highscore.formatSong(name, difficultyNum);
			Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			FlxG.state.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if(game != null && game.vocals != null)
			{
				game.vocals.pause();
				game.vocals.volume = 0;
			}
			FlxG.camera.followLerp = 0;
		});

		Lua_helper.add_callback(lua, "loadGraphic", function(variable:String, image:String, ?gridX:Int = 0, ?gridY:Int = 0)
		{
			var killMe:Array<String> = variable.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			var animated = gridX != 0 || gridY != 0;

			if (killMe.length > 1)
			{
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (spr != null && image != null && image.length > 0)
			{
				spr.loadGraphic(Paths.image(image), animated, gridX, gridY);
			}
		});
		Lua_helper.add_callback(lua, "loadFrames", function(variable:String, image:String, spriteType:String = "sparrow")
		{
			var killMe:Array<String> = variable.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (spr != null && image != null && image.length > 0)
			{
				LuaUtils.loadFrames(spr, image, spriteType);
			}
		});

		Lua_helper.add_callback(lua, "getProperty", function(variable:String)
		{
			var result:Dynamic = null;
			var killMe:Array<String> = variable.split('.');
			if (killMe.length > 1)
				result = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			else
				result = LuaUtils.getVarInArray(LuaUtils.getInstance(), variable);
			return result;
		});
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic)
		{
			var killMe:Array<String> = variable.split('.');
			if (killMe.length > 1)
			{
				LuaUtils.setVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1], value);
				return true;
			}
			LuaUtils.setVarInArray(LuaUtils.getInstance(), variable, value);
			return true;
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic)
		{
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (shitMyPants.length > 1)
				realObject = LuaUtils.getPropertyLoopThingWhatever(shitMyPants, true, false);

			if (Std.isOfType(realObject, FlxTypedGroup))
			{
				var result:Dynamic = LuaUtils.getGroupStuff(realObject.members[index], variable);
				return result;
			}

			var leArray:Dynamic = realObject[index];
			if (leArray != null)
			{
				var result:Dynamic = null;
				if (Type.typeof(variable) == ValueType.TInt)
					result = leArray[variable];
				else
					result = LuaUtils.getGroupStuff(leArray, variable);
				return result;
			}
			luaTrace("getPropertyFromGroup: Object #" + index + " from group: " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic)
		{
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (shitMyPants.length > 1)
				realObject = LuaUtils.getPropertyLoopThingWhatever(shitMyPants, true, false);

			if (Std.isOfType(realObject, FlxTypedGroup))
			{
				LuaUtils.setGroupStuff(realObject.members[index], variable, value);
				return;
			}

			var leArray:Dynamic = realObject[index];
			if (leArray != null)
			{
				if (Type.typeof(variable) == ValueType.TInt)
				{
					leArray[variable] = value;
					return;
				}
				LuaUtils.setGroupStuff(leArray, variable, value);
			}
		});
		Lua_helper.add_callback(lua, "removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false)
		{
			if (Std.isOfType(Reflect.getProperty(LuaUtils.getInstance(), obj), FlxTypedGroup))
			{
				var sex = Reflect.getProperty(LuaUtils.getInstance(), obj).members[index];
				if (!dontDestroy)
					sex.kill();
				Reflect.getProperty(LuaUtils.getInstance(), obj).remove(sex, true);
				if (!dontDestroy)
					sex.destroy();
				return;
			}
			Reflect.getProperty(LuaUtils.getInstance(), obj).remove(Reflect.getProperty(LuaUtils.getInstance(), obj)[index]);
		});

		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String)
		{
			@:privateAccess
			var killMe:Array<String> = variable.split('.');
			if (killMe.length > 1)
			{
				var coverMeInPiss:Dynamic = LuaUtils.getVarInArray(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length - 1)
				{
					coverMeInPiss = LuaUtils.getVarInArray(coverMeInPiss, killMe[i]);
				}
				return LuaUtils.getVarInArray(coverMeInPiss, killMe[killMe.length - 1]);
			}
			return LuaUtils.getVarInArray(Type.resolveClass(classVar), variable);
		});
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic)
		{
			@:privateAccess
			var killMe:Array<String> = variable.split('.');
			if (killMe.length > 1)
			{
				var coverMeInPiss:Dynamic = LuaUtils.getVarInArray(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length - 1)
				{
					coverMeInPiss = LuaUtils.getVarInArray(coverMeInPiss, killMe[i]);
				}
				LuaUtils.setVarInArray(coverMeInPiss, killMe[killMe.length - 1], value);
				return true;
			}
			LuaUtils.setVarInArray(Type.resolveClass(classVar), variable, value);
			return true;
		});

		// shitass stuff for epic coders like me B)  *image of obama giving himself a medal*
		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String)
		{
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxBasic = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (leObj != null)
			{
				return LuaUtils.getInstance().members.indexOf(leObj);
			}
			luaTrace("getObjectOrder: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int)
		{
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxBasic = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (leObj != null)
			{
				LuaUtils.getInstance().remove(leObj, true);
				LuaUtils.getInstance().insert(position, leObj);
				return;
			}
			luaTrace("setObjectOrder: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});

		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String)
		{
			var penisExam:Dynamic = LuaUtils.tweenShit(tag, vars);
			if (penisExam != null)
			{
				variables.set(tag, FlxTween.tween(penisExam, {x: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
			else
			{
				luaTrace('doTweenX: Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String)
		{
			var penisExam:Dynamic = LuaUtils.tweenShit(tag, vars);
			if (penisExam != null)
			{
				variables.set(tag, FlxTween.tween(penisExam, {y: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
			else
			{
				luaTrace('doTweenY: Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String)
		{
			var penisExam:Dynamic = LuaUtils.tweenShit(tag, vars);
			if (penisExam != null)
			{
				variables.set(tag, FlxTween.tween(penisExam, {angle: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
			else
			{
				luaTrace('doTweenAngle: Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String)
		{
			var penisExam:Dynamic = LuaUtils.tweenShit(tag, vars);
			if (penisExam != null)
			{
				variables.set(tag, FlxTween.tween(penisExam, {alpha: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
			else
			{
				luaTrace('doTweenAlpha: Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String)
		{
			var penisExam:Dynamic = LuaUtils.tweenShit(tag, vars);
			if (penisExam != null)
			{
				variables.set(tag, FlxTween.tween(penisExam, {zoom: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
			else
			{
				luaTrace('doTweenZoom: Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String)
		{
			var penisExam:Dynamic = LuaUtils.tweenShit(tag, vars);
			if (penisExam != null)
			{
				var color:Int = Std.parseInt(targetColor);
				if (!targetColor.startsWith('0x'))
					color = Std.parseInt('0xff' + targetColor);

				var curColor:FlxColor = penisExam.color;
				curColor.alphaFloat = penisExam.alpha;
				variables.set(tag, FlxTween.color(penisExam, duration, curColor, color, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						variables.remove(tag);
						game.callOnLuas('onTweenCompleted', [tag]);
					}
				}));
			}
			else
			{
				luaTrace('doTweenColor: Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});

		// Tween shit, but for strums
		Lua_helper.add_callback(lua, "noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			LuaUtils.cancelTween(tag);
			if (note < 0)
				note = 0;
			var testicle:StrumNote = game.strumLineNotes.members[note % game.strumLineNotes.length];

			if (testicle != null)
			{
				variables.set(tag, FlxTween.tween(testicle, {x: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			LuaUtils.cancelTween(tag);
			if (note < 0)
				note = 0;
			var testicle:StrumNote = game.strumLineNotes.members[note % game.strumLineNotes.length];

			if (testicle != null)
			{
				variables.set(tag, FlxTween.tween(testicle, {y: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			LuaUtils.cancelTween(tag);
			if (note < 0)
				note = 0;
			var testicle:StrumNote = game.strumLineNotes.members[note % game.strumLineNotes.length];

			if (testicle != null)
			{
				variables.set(tag, FlxTween.tween(testicle, {angle: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			LuaUtils.cancelTween(tag);
			if (note < 0)
				note = 0;
			var testicle:StrumNote = game.strumLineNotes.members[note % game.strumLineNotes.length];

			if (testicle != null)
			{
				variables.set(tag, FlxTween.tween(testicle, {direction: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "mouseClicked", function(button:String)
		{
			var boobs = FlxG.mouse.justPressed;
			switch (button)
			{
				case 'middle':
					boobs = FlxG.mouse.justPressedMiddle;
				case 'right':
					boobs = FlxG.mouse.justPressedRight;
			}

			return boobs;
		});
		Lua_helper.add_callback(lua, "mousePressed", function(button:String)
		{
			var boobs = FlxG.mouse.pressed;
			switch (button)
			{
				case 'middle':
					boobs = FlxG.mouse.pressedMiddle;
				case 'right':
					boobs = FlxG.mouse.pressedRight;
			}
			return boobs;
		});
		Lua_helper.add_callback(lua, "mouseReleased", function(button:String)
		{
			var boobs = FlxG.mouse.justReleased;
			switch (button)
			{
				case 'middle':
					boobs = FlxG.mouse.justReleasedMiddle;
				case 'right':
					boobs = FlxG.mouse.justReleasedRight;
			}
			return boobs;
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			LuaUtils.cancelTween(tag);
			if (note < 0)
				note = 0;
			var testicle:StrumNote = game.strumLineNotes.members[note % game.strumLineNotes.length];

			if (testicle != null)
			{
				variables.set(tag, FlxTween.tween(testicle, {angle: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			LuaUtils.cancelTween(tag);
			if (note < 0)
				note = 0;
			var testicle:StrumNote = game.strumLineNotes.members[note % game.strumLineNotes.length];

			if (testicle != null)
			{
				variables.set(tag, FlxTween.tween(testicle, {alpha: value}, duration, {
					ease: LuaUtils.getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						game.callOnLuas('onTweenCompleted', [tag]);
						variables.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String)
		{
			LuaUtils.cancelTween(tag);
		});

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1)
		{
			LuaUtils.cancelTimer(tag);
			variables.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer)
			{
				if (tmr.finished)
				{
					variables.remove(tag);
				}
				game.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
				// trace('Timer Completed: ' + tag);
			}, loops));
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String)
		{
			LuaUtils.cancelTimer(tag);
		});

		// stupid bietch ass functions
		Lua_helper.add_callback(lua, "addScore", function(value:Int = 0)
		{
			game.songScore += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addMisses", function(value:Int = 0)
		{
			game.songMisses += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addHits", function(value:Int = 0)
		{
			game.songHits += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setScore", function(value:Int = 0)
		{
			game.songScore = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setMisses", function(value:Int = 0)
		{
			game.songMisses = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setHits", function(value:Int = 0)
		{
			game.songHits = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "getScore", function()
		{
			return game.songScore;
		});
		Lua_helper.add_callback(lua, "getMisses", function()
		{
			return game.songMisses;
		});
		Lua_helper.add_callback(lua, "getHits", function()
		{
			return game.songHits;
		});

		Lua_helper.add_callback(lua, "setHealth", function(value:Float = 0)
		{
			game.health = value;
		});
		Lua_helper.add_callback(lua, "addHealth", function(value:Float = 0)
		{
			game.health += value;
		});
		Lua_helper.add_callback(lua, "getHealth", function()
		{
			return game.health;
		});

		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String)
		{
			if (!color.startsWith('0x'))
				color = '0xff' + color;
			return Std.parseInt(color);
		});

		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.justPressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.pressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.justReleased, name);
		});

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String)
		{
			return FlxG.gamepads.anyJustPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String)
		{
			return FlxG.gamepads.anyPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String)
		{
			return FlxG.gamepads.anyJustReleased(name);
		});

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return 0.0;
			}
			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return 0.0;
			}
			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.pressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String)
		{
			var key:Bool = false;
			switch (name)
			{
				case 'left':
					key = game.getControl('NOTE_LEFT_P');
				case 'down':
					key = game.getControl('NOTE_DOWN_P');
				case 'up':
					key = game.getControl('NOTE_UP_P');
				case 'right':
					key = game.getControl('NOTE_RIGHT_P');
				case 'accept':
					key = game.getControl('ACCEPT');
				case 'back':
					key = game.getControl('BACK');
				case 'pause':
					key = game.getControl('PAUSE');
				case 'reset':
					key = game.getControl('RESET');
				case 'space':
					key = FlxG.keys.justPressed.SPACE; // an extra key for convinience
			}
			return key;
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String)
		{
			var key:Bool = false;
			switch (name)
			{
				case 'left':
					key = game.getControl('NOTE_LEFT');
				case 'down':
					key = game.getControl('NOTE_DOWN');
				case 'up':
					key = game.getControl('NOTE_UP');
				case 'right':
					key = game.getControl('NOTE_RIGHT');
				case 'space':
					key = FlxG.keys.pressed.SPACE; // an extra key for convinience
			}
			return key;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String)
		{
			var key:Bool = false;
			switch (name)
			{
				case 'left':
					key = game.getControl('NOTE_LEFT_R');
				case 'down':
					key = game.getControl('NOTE_DOWN_R');
				case 'up':
					key = game.getControl('NOTE_UP_R');
				case 'right':
					key = game.getControl('NOTE_RIGHT_R');
				case 'space':
					key = FlxG.keys.justReleased.SPACE; // an extra key for convinience
			}
			return key;
		});
		Lua_helper.add_callback(lua, "addCharacterToList", function(name:String, type:String)
		{
			var charType:Int = 0;
			switch (type.toLowerCase())
			{
				case 'dad':
					charType = 1;
				case 'gf' | 'girlfriend':
					charType = 2;
			}
			game.addCharacterToList(name, charType);
		});
		Lua_helper.add_callback(lua, "precacheImage", function(name:String, ?allowGPU:Bool = true) {
			Paths.image(name);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			Paths.sound(name);
		});
		Lua_helper.add_callback(lua, "precacheMusic", function(name:String) {
			Paths.music(name);
		});
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic)
		{
			var value1:String = arg1;
			var value2:String = arg2;
			game.triggerEvent(name, value1, value2, Conductor.songPosition);
			// trace('Triggered event: ' + name + ', ' + value1 + ', ' + value2);
			return true;
		});

		Lua_helper.add_callback(lua, "startCountdown", function()
		{
			game.startCountdown();
			return true;
		});
		Lua_helper.add_callback(lua, "endSong", function()
		{
			game.KillNotes();
			game.endSong();
			return true;
		});
		Lua_helper.add_callback(lua, "restartSong", function(?skipTransition:Bool = false)
		{
			game.persistentUpdate = false;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		Lua_helper.add_callback(lua, "exitSong", function(?skipTransition:Bool = false)
		{
			if (skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			PlayState.cancelMusicFadeTween();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new funkin.game.states.StoryMenuState());
			else
				MusicBeatState.switchState(new funkin.game.states.FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			game.transitioning = true;
			Mods.loadTopMod();
			return true;
		});
		Lua_helper.add_callback(lua, "getSongPosition", function()
		{
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "getCharacterX", function(type:String)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					return game.dadGroup.x;
				case 'gf' | 'girlfriend':
					return game.gfGroup.x;
				default:
					return game.boyfriendGroup.x;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterX", function(type:String, value:Float)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					game.dadGroup.x = value;
				case 'gf' | 'girlfriend':
					game.gfGroup.x = value;
				default:
					game.boyfriendGroup.x = value;
			}
		});
		Lua_helper.add_callback(lua, "getCharacterY", function(type:String)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					return game.dadGroup.y;
				case 'gf' | 'girlfriend':
					return game.gfGroup.y;
				default:
					return game.boyfriendGroup.y;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterY", function(type:String, value:Float)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					game.dadGroup.y = value;
				case 'gf' | 'girlfriend':
					game.gfGroup.y = value;
				default:
					game.boyfriendGroup.y = value;
			}
		});
		Lua_helper.add_callback(lua, "cameraSetTarget", function(target:String)
		{
			var isDad:Bool = false;
			if (target == 'dad')
			{
				isDad = true;
			}
			game.moveCamera(isDad);
			return isDad;
		});
		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float)
		{
			LuaUtils.cameraFromString(camera).shake(intensity, duration);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float, forced:Bool)
		{
			var colorNum:Int = Std.parseInt(color);
			if (!color.startsWith('0x'))
				colorNum = Std.parseInt('0xff' + color);
			LuaUtils.cameraFromString(camera).flash(colorNum, duration, null, forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float, forced:Bool)
		{
			var colorNum:Int = Std.parseInt(color);
			if (!color.startsWith('0x'))
				colorNum = Std.parseInt('0xff' + color);
			LuaUtils.cameraFromString(camera).fade(colorNum, duration, false, null, forced);
		});
		Lua_helper.add_callback(lua, "setRatingPercent", function(value:Float)
		{
			game.ratingPercent = value;
		});
		Lua_helper.add_callback(lua, "setRatingName", function(value:String)
		{
			game.ratingName = value;
		});
		Lua_helper.add_callback(lua, "setRatingFC", function(value:String)
		{
			game.ratingFC = value;
		});
		Lua_helper.add_callback(lua, "getMouseX", function(camera:String)
		{
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});
		Lua_helper.add_callback(lua, "getMouseY", function(camera:String)
		{
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});

		Lua_helper.add_callback(lua, "getMidpointX", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}
			if (obj != null)
				return obj.getMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}
			if (obj != null)
				return obj.getMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}
			if (obj != null)
				return obj.getGraphicMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}
			if (obj != null)
				return obj.getGraphicMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}
			if (obj != null)
				return obj.getScreenPosition().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				obj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}
			if (obj != null)
				return obj.getScreenPosition().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "characterDance", function(character:String)
		{
			switch (character.toLowerCase())
			{
				case 'dad':
					game.dad.dance();
				case 'gf' | 'girlfriend':
					if (game.gf != null)
						game.gf.dance();
				default:
					game.boyfriend.dance();
			}
		});

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String, x:Float, y:Float)
		{
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			if (image != null && image.length > 0)
			{
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = ClientPrefs.data.globalAntialiasing;
			variables.set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, ?spriteType:String = "sparrow")
		{
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);

			LuaUtils.loadFrames(leSprite, image, spriteType);
			leSprite.antialiasing = ClientPrefs.data.globalAntialiasing;
			variables.set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphic", function(obj:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF')
		{
			var spr:FlxSprite = LuaUtils.getObjectDirectly(obj);
			if (spr != null)
				spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
		});

		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true)
		{
			if (game.getLuaObject(obj, false) != null)
			{
				var cock:FlxSprite = game.getLuaObject(obj, false);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if (cock.animation.curAnim == null)
				{
					cock.animation.play(name, true);
				}
				return;
			}

			var cock:FlxSprite = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (cock != null)
			{
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if (cock.animation.curAnim == null)
				{
					cock.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true)
		{
			if (game.getLuaObject(obj, false) != null)
			{
				var cock:FlxSprite = game.getLuaObject(obj, false);
				cock.animation.add(name, frames, framerate, loop);
				if (cock.animation.curAnim == null)
				{
					cock.animation.play(name, true);
				}
				return;
			}

			var cock:FlxSprite = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (cock != null)
			{
				cock.animation.add(name, frames, framerate, loop);
				if (cock.animation.curAnim == null)
				{
					cock.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24)
		{
			return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, false);
		});
		Lua_helper.add_callback(lua, "addAnimationByIndicesLoop", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24)
		{
			return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, true);
		});

		Lua_helper.add_callback(lua, "playAnim", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
		{
			if (game.getLuaObject(obj, false) != null)
			{
				var luaObj:FlxSprite = game.getLuaObject(obj, false);
				if (luaObj.animation.getByName(name) != null)
				{
					luaObj.animation.play(name, forced, reverse, startFrame);
					if (Std.isOfType(luaObj, ModchartSprite))
					{
						// convert luaObj to ModchartSprite
						var obj:Dynamic = luaObj;
						var luaObj:ModchartSprite = obj;

						var daOffset = luaObj.animOffsets.get(name);
						if (luaObj.animOffsets.exists(name))
						{
							luaObj.offset.set(daOffset[0], daOffset[1]);
						}
					}
				}
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (spr != null)
			{
				if (spr.animation.getByName(name) != null)
				{
					if (Std.isOfType(spr, Character))
					{
						// convert spr to Character
						var obj:Dynamic = spr;
						var spr:Character = obj;
						spr.playAnim(name, forced, reverse, startFrame);
					}
					else
						spr.animation.play(name, forced, reverse, startFrame);
				}
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "addOffset", function(obj:String, anim:String, x:Float, y:Float)
		{
			if (variables.exists(obj))
			{
				variables.get(obj).animOffsets.set(anim, [x, y]);
				return true;
			}

			var char:Character = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (char != null)
			{
				char.addOffset(anim, x, y);
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float)
		{
			if (game.getLuaObject(obj, false) != null)
			{
				game.getLuaObject(obj, false).scrollFactor.set(scrollX, scrollY);
				return;
			}

			var object:FlxObject = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (object != null)
			{
				object.scrollFactor.set(scrollX, scrollY);
			}
		});
		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, front:Bool = false) {
			var mySprite:FlxSprite = MusicBeatState.getVariables().get(tag);
			if(mySprite == null) return false;

			var instance = LuaUtils.getTargetInstance();
			if(front)
				instance.add(mySprite);
			else
			{
				if(PlayState.instance == null || !PlayState.instance.isDead)
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), mySprite);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
			}
			return true;
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true)
		{
			if (game.getLuaObject(obj) != null)
			{
				var shit:FlxSprite = game.getLuaObject(obj);
				shit.setGraphicSize(x, y);
				if (updateHitbox)
					shit.updateHitbox();
				return;
			}

			var killMe:Array<String> = obj.split('.');
			var poop:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (poop != null)
			{
				poop.setGraphicSize(x, y);
				if (updateHitbox)
					poop.updateHitbox();
				return;
			}
			luaTrace('setGraphicSize: Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true)
		{
			if (game.getLuaObject(obj) != null)
			{
				var shit:FlxSprite = game.getLuaObject(obj);
				shit.scale.set(x, y);
				if (updateHitbox)
					shit.updateHitbox();
				return;
			}

			var killMe:Array<String> = obj.split('.');
			var poop:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				poop = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (poop != null)
			{
				poop.scale.set(x, y);
				if (updateHitbox)
					poop.updateHitbox();
				return;
			}
			luaTrace('scaleObject: Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String)
		{
			if (game.getLuaObject(obj) != null)
			{
				var shit:FlxSprite = game.getLuaObject(obj);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (poop != null)
			{
				poop.updateHitbox();
				return;
			}
			luaTrace('updateHitbox: Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitboxFromGroup", function(group:String, index:Int)
		{
			if (Std.isOfType(Reflect.getProperty(LuaUtils.getInstance(), group), FlxTypedGroup))
			{
				Reflect.getProperty(LuaUtils.getInstance(), group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(LuaUtils.getInstance(), group)[index].updateHitbox();
		});

		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true, ?group:String = null) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
			if(obj == null || obj.destroy == null)
				return;
			
			var groupObj:Dynamic = null;
			if(group == null) groupObj = LuaUtils.getTargetInstance();
			else groupObj = LuaUtils.getObjectDirectly(group);

			groupObj.remove(obj, true);
			if(destroy)
			{
				MusicBeatState.getVariables().remove(tag);
				obj.destroy();
			}
		});

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String)
		{
			return variables.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaTextExists", function(tag:String)
		{
			return variables.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaSoundExists", function(tag:String)
		{
			return variables.exists(tag);
		});

		Lua_helper.add_callback(lua, "setHealthBarColors", function(left:String, right:String) {
			var left_color:Null<FlxColor> = null;
			var right_color:Null<FlxColor> = null;
			if (left != null && left != '')
				left_color = CoolUtil.colorFromString(left);
			if (right != null && right != '')
				right_color = CoolUtil.colorFromString(right);
			game.healthBar.setColors(left_color, right_color);
		});
		Lua_helper.add_callback(lua, "setTimeBarColors", function(left:String, right:String) {
			var left_color:Null<FlxColor> = null;
			var right_color:Null<FlxColor> = null;
			if (left != null && left != '')
				left_color = CoolUtil.colorFromString(left);
			if (right != null && right != '')
				right_color = CoolUtil.colorFromString(right);
			game.timeBar.setColors(left_color, right_color);
		});

		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = '')
		{
			/*if(variables.exists(obj)) {
					variables.get(obj).cameras = [cameraFromString(camera)];
					return true;
				}
				else if(variables.exists(obj)) {
					variables.get(obj).cameras = [cameraFromString(camera)];
					return true;
			}*/
			var real = game.getLuaObject(obj);
			if (real != null)
			{
				real.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}

			var killMe:Array<String> = obj.split('.');
			var object:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (object != null)
			{
				object.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			luaTrace("setObjectCamera: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '')
		{
			var real = game.getLuaObject(obj);
			if (real != null)
			{
				real.blend = LuaUtils.blendModeFromString(blend);
				return true;
			}

			var killMe:Array<String> = obj.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (spr != null)
			{
				spr.blend = LuaUtils.blendModeFromString(blend);
				return true;
			}
			luaTrace("setBlendMode: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy')
		{
			var spr:FlxSprite = game.getLuaObject(obj);

			if (spr == null)
			{
				var killMe:Array<String> = obj.split('.');
				spr = LuaUtils.getObjectDirectly(killMe[0]);
				if (killMe.length > 1)
					spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (spr != null)
			{
				final i = ObjectUtils.convertFlxAxes(pos.trim());
				spr.screenCenter(i);
				return;
			}
			luaTrace("screenCenter: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});
		
		Lua_helper.add_callback(lua, "objectsOverlap", function(obj1:String, obj2:String)
		{
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				var real = game.getLuaObject(namesArray[i]);
				if (real != null)
				{
					objectsArray.push(real);
				}
				else
				{
					objectsArray.push(Reflect.getProperty(LuaUtils.getInstance(), namesArray[i]));
				}
			}

			if (!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
			{
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPixelColor", function(obj:String, x:Int, y:Int)
		{
			var killMe:Array<String> = obj.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
			if (killMe.length > 1)
			{
				spr = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
			}

			if (spr != null)
			{
				if (spr.framePixels != null)
					spr.framePixels.getPixel32(x, y);
				return spr.pixels.getPixel32(x, y);
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '')
		{
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '')
		{
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50)
		{
			return FlxG.random.bool(chance);
		});
		Lua_helper.add_callback(lua, "startDialogue", function(dialogueFile:String, music:String = null)
		{
			var path:String;
			#if MODS_ALLOWED
			path = Paths.modsJson(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);
			if (!FileSystem.exists(path))
			#end
			path = Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);

			luaTrace('startDialogue: Trying to load dialogue: ' + path);

			#if MODS_ALLOWED
			if (FileSystem.exists(path))
			#else
			if (Assets.exists(path))
			#end
			{
				var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
				if (shit.dialogue.length > 0)
				{
					game.startDialogue(shit, music);
					luaTrace('startDialogue: Successfully loaded dialogue', false, false, FlxColor.GREEN);
					return true;
				}
				else
				{
					luaTrace('startDialogue: Your dialogue file is badly formatted!', false, false, FlxColor.RED);
				}
			}
		else
		{
			luaTrace('startDialogue: Dialogue file not found', false, false, FlxColor.RED);
			if (game.endingSong)
			{
				game.endSong();
			}
			else
			{
				game.startCountdown();
			}
		}
			return false;
		});
		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String)
		{
			#if VIDEOS_ALLOWED
			if (FileSystem.exists(Paths.video(videoFile)))
			{
				game.startVideo(videoFile);
				return true;
			}
			else
			{
				luaTrace('startVideo: Video file not found: ' + videoFile, false, false, FlxColor.RED);
			}
			return false;
			#else
			if (game.endingSong)
			{
				game.endSong();
			}
			else
			{
				game.startCountdown();
			}
			return true;
			#end
		});

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false)
		{
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null)
		{
			if (tag != null && tag.length > 0)
			{
				tag = tag.replace('.', '');
				if (variables.exists(tag))
				{
					variables.get(tag).stop();
				}
				variables.set(tag, FlxG.sound.play(Paths.sound(sound), volume, false, function()
				{
					variables.remove(tag);
					game.callOnLuas('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});
		Lua_helper.add_callback(lua, "stopSound", function(tag:String)
		{
			if (tag != null && tag.length > 1 && variables.exists(tag))
			{
				variables.get(tag).stop();
				variables.remove(tag);
			}
		});
		Lua_helper.add_callback(lua, "pauseSound", function(tag:String)
		{
			if (tag != null && tag.length > 1 && variables.exists(tag))
			{
				variables.get(tag).pause();
			}
		});
		Lua_helper.add_callback(lua, "resumeSound", function(tag:String)
		{
			if (tag != null && tag.length > 1 && variables.exists(tag))
			{
				variables.get(tag).play();
			}
		});
		Lua_helper.add_callback(lua, "soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1)
		{
			if (tag == null || tag.length < 1)
			{
				FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			}
			else if (variables.exists(tag))
			{
				variables.get(tag).fadeIn(duration, fromValue, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0)
		{
			if (tag == null || tag.length < 1)
			{
				FlxG.sound.music.fadeOut(duration, toValue);
			}
			else if (variables.exists(tag))
			{
				variables.get(tag).fadeOut(duration, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeCancel", function(tag:String)
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music.fadeTween != null)
				{
					FlxG.sound.music.fadeTween.cancel();
				}
			}
			else if (variables.exists(tag))
			{
				var theSound:FlxSound = variables.get(tag);
				if (theSound.fadeTween != null)
				{
					theSound.fadeTween.cancel();
					variables.remove(tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "getSoundVolume", function(tag:String)
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
				{
					return FlxG.sound.music.volume;
				}
			}
			else if (variables.exists(tag))
			{
				return variables.get(tag).volume;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundVolume", function(tag:String, value:Float)
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.volume = value;
				}
			}
			else if (variables.exists(tag))
			{
				variables.get(tag).volume = value;
			}
		});
		Lua_helper.add_callback(lua, "getSoundTime", function(tag:String)
		{
			if (tag != null && tag.length > 0 && variables.exists(tag))
			{
				return variables.get(tag).time;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundTime", function(tag:String, value:Float)
		{
			if (tag != null && tag.length > 0 && variables.exists(tag))
			{
				var theSound:FlxSound = variables.get(tag);
				if (theSound != null)
				{
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.time = value;
					if (wasResumed)
						theSound.play();
				}
			}
		});

		Lua_helper.add_callback(lua, "debugPrint", function(text1:Dynamic = '', text2:Dynamic = '', text3:Dynamic = '', text4:Dynamic = '', text5:Dynamic = '')
		{
			if (text1 == null)
				text1 = '';
			if (text2 == null)
				text2 = '';
			if (text3 == null)
				text3 = '';
			if (text4 == null)
				text4 = '';
			if (text5 == null)
				text5 = '';
			luaTrace('' + text1 + text2 + text3 + text4 + text5, true, false);
		});

		ShaderFunctions.implement(this);
		TextFunctions.implement(this);
		SaveFunctions.implement(this);

		for (name => func in customFunctions)
		{
			if (func != null)
				Lua_helper.add_callback(lua, name, func);
		}

		Lua_helper.add_callback(lua, "close", function()
		{
			closed = true;
			return closed;
		});

		Lua_helper.add_callback(lua, "changePresence",
			function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
			{
				#if desktop
				DiscordClient.changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
				#end
			});

		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false)
		{
			#if MODS_ALLOWED
			if (absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if (FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists(Paths.getPath('assets/$filename', TEXT));
			#else
			if (absolute)
			{
				return Assets.exists(filename);
			}
			return Assets.exists(Paths.getPath('assets/$filename', TEXT));
			#end
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try
			{
				if (!absolute)
					File.saveContent(Paths.mods(path), content);
				else
					File.saveContent(path, content);

				return true;
			}
			catch (e:Dynamic)
			{
				luaTrace("saveFile: Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			try
			{
				#if MODS_ALLOWED
				if (!ignoreModFolders)
				{
					var lePath:String = Paths.modFolders(path);
					if (FileSystem.exists(lePath))
					{
						FileSystem.deleteFile(lePath);
						return true;
					}
				}
				#end

				var lePath:String = Paths.getPath(path, TEXT);
				if (Assets.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			}
			catch (e:Dynamic)
			{
				luaTrace("deleteFile: Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			return Paths.getTextFromFile(path, ignoreModFolders);
		});

		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0)
		{
			luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
			if (game.getLuaObject(obj, false) != null)
			{
				game.getLuaObject(obj, false).animation.play(name, forced, false, startFrame);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(LuaUtils.getInstance(), obj);
			if (spr != null)
			{
				spr.animation.play(name, forced, false, startFrame);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false)
		{
			luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);
			switch (character.toLowerCase())
			{
				case 'dad':
					if (game.dad.animOffsets.exists(anim))
						game.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if (game.gf != null && game.gf.animOffsets.exists(anim))
						game.gf.playAnim(anim, forced);
				default:
					if (game.boyfriend.animOffsets.exists(anim))
						game.boyfriend.playAnim(anim, forced);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String)
		{
			luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);
			if (variables.exists(tag))
			{
				var colorNum:Int = Std.parseInt(color);
				if (!color.startsWith('0x'))
					colorNum = Std.parseInt('0xff' + color);

				variables.get(tag).makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true)
		{
			luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
			if (variables.exists(tag))
			{
				var cock:ModchartSprite = variables.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if (cock.animation.curAnim == null)
				{
					cock.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24)
		{
			luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
			if (variables.exists(tag))
			{
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length)
				{
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:ModchartSprite = variables.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if (pussy.animation.curAnim == null)
				{
					pussy.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false)
		{
			luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			if (variables.exists(tag))
			{
				variables.get(tag).animation.play(name, forced);
			}
		});
		Lua_helper.add_callback(lua, "setLuaSpriteCamera", function(tag:String, camera:String = '')
		{
			luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);
			if (variables.exists(tag))
			{
				variables.get(tag).cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float)
		{
			luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);
			if (variables.exists(tag))
			{
				variables.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "scaleLuaSprite", function(tag:String, x:Float, y:Float)
		{
			luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);
			if (variables.exists(tag))
			{
				var shit:ModchartSprite = variables.get(tag);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPropertyLuaSprite", function(tag:String, variable:String)
		{
			luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);
			if (variables.exists(tag))
			{
				var killMe:Array<String> = variable.split('.');
				if (killMe.length > 1)
				{
					var coverMeInPiss:Dynamic = Reflect.getProperty(variables.get(tag), killMe[0]);
					for (i in 1...killMe.length - 1)
					{
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length - 1]);
				}
				return Reflect.getProperty(variables.get(tag), variable);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic)
		{
			luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);
			if (variables.exists(tag))
			{
				var killMe:Array<String> = variable.split('.');
				if (killMe.length > 1)
				{
					var coverMeInPiss:Dynamic = Reflect.getProperty(variables.get(tag), killMe[0]);
					for (i in 1...killMe.length - 1)
					{
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					Reflect.setProperty(coverMeInPiss, killMe[killMe.length - 1], value);
					return true;
				}
				Reflect.setProperty(variables.get(tag), variable, value);
				return true;
			}
			luaTrace("setPropertyLuaSprite: Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1)
		{
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);
		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0)
		{
			FlxG.sound.music.fadeOut(duration, toValue);
			luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
		});

		// Other stuff
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String)
		{
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String)
		{
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String)
		{
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String)
		{
			return str.trim();
		});

		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String)
		{
			var list:Array<String> = [];
			#if sys
			if (FileSystem.exists(folder))
			{
				for (folder in FileSystem.readDirectory(folder))
				{
					if (!list.contains(folder))
					{
						list.push(folder);
					}
				}
			}
			#end
			return list;
		});

		call('onCreate', []);
		#end
	}

	#if HSCRIPT_ALLOWED
	public function initHaxeModule()
	{
		if (hscript == null)
		{
			trace('Initializing Haxe Interp: $scriptName');
			hscript = new HScript(); // TO DO: Fix issue with 2 scripts not being able to use the same variable names
		}
	}
	#end

	#if (!flash && sys)
	public function getShader(obj:String):FlxRuntimeShader
	{
		var killMe:Array<String> = obj.split('.');
		var leObj:FlxSprite = LuaUtils.getObjectDirectly(killMe[0]);
		if (killMe.length > 1)
		{
			leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoopThingWhatever(killMe), killMe[killMe.length - 1]);
		}

		if (leObj != null)
		{
			var shader:Dynamic = leObj.shader;
			var shader:FlxRuntimeShader = shader;
			return shader;
		}
		return null;
	}
	#end

	#if (MODS_ALLOWED && !flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	#end

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if (!ClientPrefs.data.shaders)
			return false;

		#if (MODS_ALLOWED && !flash && sys)
		if (runtimeShaders.exists(name))
		{
			var shaderData:Array<String> = runtimeShaders.get(name);
			if (shaderData != null && (shaderData[0] != null || shaderData[1] != null))
			{
				luaTrace('Shader $name was already initialized!');
				return true;
			}
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods( Mods.currentModDirectory+ '/shaders/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if (FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else
					frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else
					vert = null;

				if (found)
				{
					runtimeShaders.set(name, [frag, vert]);
					// trace('Found shader $name!');
					return true;
				}
			}
		}
		luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
		#else
		luaTrace('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
		#end
		return false;
	}

	public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE)
	{
		#if LUA_ALLOWED
		if (ignoreCheck || getBool('luaDebugMode'))
		{
			if (deprecated && !getBool('luaDeprecatedWarnings'))
			{
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
			trace(text);
		}
		#end
	}

	function getErrorMessage(status:Int):String
	{
		#if LUA_ALLOWED
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null)
			v = v.trim();
		if (v == null || v == "")
		{
			switch (status)
			{
				case Lua.LUA_ERRRUN:
					return "Runtime Error";
				case Lua.LUA_ERRMEM:
					return "Memory Allocation Error";
				case Lua.LUA_ERRERR:
					return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		#end
		return null;
	}

	public function addLocalCallback(name:String, myFunction:Dynamic)
	{
		callbacks.set(name, myFunction);
		Lua_helper.add_callback(lua, name, null); // just so that it gets called
	}

	public var lastCalledFunction:String = '';

	public static var lastCalledScript:FunkinLua = null;

	public function call(func:String, args:Array<Dynamic>):Dynamic
	{
		#if LUA_ALLOWED
		if (closed)
			return LuaUtils.Function_Continue;

		lastCalledFunction = func;
		lastCalledScript = this;
		try
		{
			if (lua == null)
				return LuaUtils.Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION)
			{
				if (type > Lua.LUA_TNIL)
					luaTrace("ERROR (" + func + "): attempt to call a " + typeToString(type) + " value", false, false, FlxColor.RED);

				Lua.pop(lua, 1);
				return LuaUtils.Function_Continue;
			}

			for (arg in args)
				Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK)
			{
				var error:String = getErrorMessage(status);
				luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
				return LuaUtils.Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null)
				result = LuaUtils.Function_Continue;

			Lua.pop(lua, 1);
			return result;
		}
		catch (e:Dynamic)
		{
			trace(e);
		}
		#end
		return LuaUtils.Function_Continue;
	}

	function typeToString(type:Int):String
	{
		#if LUA_ALLOWED
		switch (type)
		{
			case Lua.LUA_TBOOLEAN:
				return "boolean";
			case Lua.LUA_TNUMBER:
				return "number";
			case Lua.LUA_TSTRING:
				return "string";
			case Lua.LUA_TTABLE:
				return "table";
			case Lua.LUA_TFUNCTION:
				return "function";
		}
		if (type <= Lua.LUA_TNIL)
			return "nil";
		#end
		return "unknown";
	}

	public function set(variable:String, data:Dynamic)
	{
		#if LUA_ALLOWED
		if (lua == null)
		{
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
		#end
	}

	public static function getBool(variable:String)
	{
		if (lastCalledScript == null)
			return false;

		var lua:State = lastCalledScript.lua;
		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return false;
		}
		return (result == 'true');
	}

	function findScript(scriptFile:String, ext:String = '.lua')
	{
		if (!scriptFile.endsWith(ext))
			scriptFile += ext;
		var preloadPath:String = Paths.getSharedPath(scriptFile);
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(scriptFile);
		if (FileSystem.exists(scriptFile))
			return scriptFile;
		else if (FileSystem.exists(path))
			return path;

		if (FileSystem.exists(preloadPath))
		#else
		if (Assets.exists(preloadPath))
		#end
		{
			return preloadPath;
		}
		return null;
	}

	public function stop()
	{
		#if LUA_ALLOWED
		if (lua == null)
		{
			return;
		}

		Lua.close(lua);
		lua = null;
		#end
	}
}
