package funkin.backend.utils;

import funkin.backend.system.initialization.Volume;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

@:structInit class SaveVariables
{
	public var antialiasing:Bool = true;

	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var autoPause:Bool = true;
	public var noteSplashes:Bool = true;
	public var opnoteSplashes:Bool = true;
	public var lowQuality:Bool = false;
	public var hideHud:Bool = false;
	public var botplayEnabled:Bool = false;
	#if SHADERS_ALLOWED
	public var shaders:Bool = true;
	#end
	public var cacheOnGPU:Bool = #if !switch false #else true #end;// GPU Caching made by Raltyro
	public var framerate:Int = 60;
	public var cursing:Bool = true;
	public var violence:Bool = true;
	public var camZooms:Bool = true;
	public var noteOffset:Int = 0;
	public var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public var ghostTapping:Bool = true;
	public var hitSound:Bool = false;
	public var timeBarType:String = 'Time Left';
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var fpsCounterAlpha:Float = 1;
	public var controllerMode:Bool = false;
	public var mouseEvents:Bool = false;
	public var hitsoundVolume:Float = 0;
	public var pauseMusic:String = 'Tea Time';
	public var checkForUpdates:Bool = true;
	public var comboStacking = true;
	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;

	// Notes
	public var noteSkin:String = 'Default';
	public var splashSkin:String = 'Psych';
	public var splashAlpha:Float = 0.6;
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
	];

	// Astro Engine
	public var discordRPC:Bool = true;
	public var scoreBarType:String = 'Astro';
	public var forceNoteSplashes:Bool = false;
	public var showRatingStats:Bool = true;
	
	#if WINDOW_CUSTOMIZATION public var darkmodeEnabled:Bool = false; #end
	#if ASTRO_WATERMARKS public var goober:Bool = false; #end

	public var stats:Map<String, Dynamic> = ['Max Misses' => 0, 'Max Score' => 0];

	public var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
}

class ClientPrefs
{
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_up' => [W, UP],
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_right' => [D, RIGHT],
		'ui_up' => [W, UP],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume_mute' => [ZERO],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN],
		'debug_2' => [EIGHT]
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up' => [DPAD_UP, Y],
		'note_left' => [DPAD_LEFT, X],
		'note_down' => [DPAD_DOWN, A],
		'note_right' => [DPAD_RIGHT, B],
		'ui_up' => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left' => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down' => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right' => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		'accept' => [A, START],
		'back' => [B],
		'pause' => [START],
		'reset' => [BACK]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
		{
			if(controller != true)
				for (key in keyBinds.keys())
					if(defaultKeys.exists(key))
						keyBinds.set(key, defaultKeys.get(key).copy());
	
			if(controller != false)
				for (button in gamepadBinds.keys())
					if(defaultButtons.exists(button))
						gamepadBinds.set(button, defaultButtons.get(button).copy());
		}


		public static function clearInvalidKeys(key:String)
			{
				var keyBind:Array<FlxKey> = keyBinds.get(key);
				var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
				while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
				while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
			}
		
			public static function loadDefaultKeys()
			{
				defaultKeys = keyBinds.copy();
				defaultButtons = gamepadBinds.copy();
			}

	// public static function loadDefaultKeys()
	// {
	// 	defaultKeys = keyBinds.copy();
	// 	// trace(defaultKeys);
	// }

	public static function saveSettings()
	{
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		FlxG.save.flush();

		try{
			final save:FlxSave = new FlxSave();
			save.bind('controls_v2',
				CoolUtil.getSavePath()); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
			save.data.customControls = keyBinds;
			save.flush();
			FlxG.log.notice("Successfully saved settings.");
		} catch(e:Dynamic)
			FlxG.log.error("Failed to save settings.");
	}

	public static function loadPrefs()
	{
		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && key != 'stats' && key != 'achievementsMap' && Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		#if (!html5 && !switch)
		if (FlxG.save.data.framerate == null)
			data.framerate = Std.int(FlxMath.bound(FlxG.stage.application.window.displayMode.refreshRate, 60, 240));
		#end

		/*if (data.framerate > FlxG.drawFramerate) ????
		{
			FlxG.updateFramerate = FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		} */

		if (FlxG.save.data.gameplaySettings != null)
		{
			final savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}

		if (FlxG.save.data.stats != null)
		{
			final savedMap:Map<String, Int> = FlxG.save.data.stats;
			for (name => value in savedMap)
				data.stats.set(name, value);
		}

		if (FlxG.save.data.achievementsMap != null)
		{
			final savedMap:Map<String, Bool> = FlxG.save.data.achievementsMap;
			for (name => value in savedMap)
				data.achievementsMap.set(name, value);
		}

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if DISCORD_ALLOWED
		DiscordClient.checkClientID();
		#end

		final save:FlxSave = new FlxSave();
		save.bind('controls_v2', CoolUtil.getSavePath());
		if (save != null && save.data.customControls != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls)
				keyBinds.set(control, keys);
		}

		reloadVolumeKeys();
	}

	public static function init():Void
	{
		var is:Bool = false;
		try
		{
			loadPrefs();
			saveSettings();
			is = true;
		}
		catch (e) {}
		//Logs.defaultTrace('e');
		Logs.prefixedTrace('Loaded ClientPrefs : ${Std.string(is).toUpperCase()}','User Preferences', GREEN);
		return;
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic
	{
		if (!customDefaultValue)
			defaultValue = defaultData.gameplaySettings.get(name);
		return (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadVolumeKeys()
	{
		Volume.muteKeys = copyKey(keyBinds.get('volume_mute'));
		Volume.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		Volume.volumeUpKeys = copyKey(keyBinds.get('volume_up'));

		toggleVolumeKeys(true);
	}

	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		final emptyArray = [];
		FlxG.sound.muteKeys = turnOn ? Volume.muteKeys : emptyArray;
		FlxG.sound.volumeDownKeys = turnOn ? Volume.volumeDownKeys : emptyArray;
		FlxG.sound.volumeUpKeys = turnOn ? Volume.volumeUpKeys : emptyArray;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
