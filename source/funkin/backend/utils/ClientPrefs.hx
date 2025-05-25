package funkin.backend.utils;

import haxe.ds.StringMap;
import funkin.backend.system.initialization.Volume;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

@:structInit class SaveVariables
{
	/**
	 * Global antialiasing, basically makes everything look sharp and crisp.
	 */
	public var antialiasing:Bool = true;

	/**
	 * Down Scroll.
	 */
	public var downScroll:Bool = false;

	/**
	 * Middle Scroll.
	 */
	public var middleScroll:Bool = false;

	/**
	 * Opponent strums.
	 */
	public var opponentStrums:Bool = true;

	/**
	 * Show FPS
	 */
	public var showFPS:Bool = true;

	/**
	 * Flashing lights.
	 */
	public var flashing:Bool = true;

	/**
	 * Auto pause.
	 */
	public var autoPause:Bool = true;

	/**
	 * Note splashes
	 */
	public var noteSplashes:Bool = true;

	/**
	 * Opponent note splashes.
	 */
	public var oppNoteSplashes:Bool = true;

	/**
	 * Low quality mode.
	 */
	public var lowQuality:Bool = false;

	/**
	 * Should the hud be hidden.
	 */
	public var hideHud:Bool = false;

	/**
	 * Botplay enabled...
	 */
	public var botplayEnabled:Bool = false;

	#if SHADERS_ALLOWED
	/**
	 * Should shaders be allowed.
	 */
	public var shaders:Bool = true;
	#end

	/**
	 * CPU caching, decreases memory usage by pushing some of the load to the gpu.
	 * Made by Raltyro	
	 */
	public var cacheOnGPU:Bool = #if !switch false #else true #end;

	/**
	 * The framerate.
	 */
	public var framerate:Int = 60;

	/**
	 * Cursing
	 */
	public var cursing:Bool = true;

	/**
	 * Violence
	 */
	public var violence:Bool = true;

	/**
	 * Camera zooms.
	 */
	public var camZooms:Bool = true;

	/**
	 * Note offset.
	 */
	public var noteOffset:Int = 0;

	/**
	 * Ghost tapping
	 */
	public var ghostTapping:Bool = true;

	/**
	 * Hit sounds
	 */
	public var hitSound:Bool = false;

	/**
	 * Time bar type.
	 */
	public var timeBarType:String = 'Time Left';

	/**
	 * Score zoom.
	 */
	public var scoreZoom:Bool = true;

	/**
	 * No reset.
	 */
	public var noReset:Bool = false;

	/**
	 * Health bar alpha.
	 */
	public var healthBarAlpha:Float = 1;

	/**
	 * Fps counter alpha.
	 */
	public var fpsCounterAlpha:Float = 1;

	/**
	 * Controller mode.
	 */
	public var controllerMode:Bool = false;

	/**
	 * Mouse events, menu support needed...
	 */
	public var mouseEvents:Bool = false;

	/**
	 * Hitsound volume
	 */
	public var hitsoundVolume:Float = 0;

	/**
	 * The Pause Music
	 */
	public var pauseMusic:String = 'Tea Time';

	/**
	 * Check for updates
	 */
	public var checkForUpdates:Bool = true;

	/**
	 * Combo stacking
	 */
	public var comboStacking = true;

	/**
	 * Gameplay settings
	 */
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

	/**
	 * Note's Combo offset.
	 */
	public var comboOffset:Array<Int> = [0, 0, 0, 0];

	/**
	 * Note's Rating Offset.
	 */
	public var ratingOffset:Int = 0;

	/**
	 * Note's Sick Window.	
	 */
	public var sickWindow:Int = 45;

	/**
	 * Note's Good Window.	
	 */
	public var goodWindow:Int = 90;

	/**
	 * Note's Bad Window.	
	 */
	public var badWindow:Int = 135;

	/**
	 * Safe Frames.	
	 */
	public var safeFrames:Float = 10;

	/**
	 * Note skin.	
	 */
	public var noteSkin:String = 'Default';

	/**
	 * Note splashes skin.	
	 */
	public var splashSkin:String = 'Psych';

	/**
	 * Note splashes alpha.	
	 */
	public var splashAlpha:Float = 0.6;

	/**
	 * Arrow RGB.	
	 */
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];

	/**
	 * Arrow RGB Pixel.	
	 */
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
	];

	/**
	 * Discord RPC toggle.	
	 */
	public var discordRPC:Bool = true;

	/**
	 * Score-bar type.	
	 */
	public var interfaceType:String = 'Astro';

	/**
	 * Hold covers	
	 */
	public var holdCovers:Bool = true;

	/**
	 * Opponent Hold splashes	
	 */
	public var oppHoldSplashes:Bool = true;

	/**
	 * The hold splashes skin.	
	 */
	public var holdSplashesSkin:String = "Normal";

	/**
	 * The hold splashes alpha.	
	 */
	public var holdSplashesAlpha:Float = 0.6;

	/**
	 * Show rating stats.
	 */
	public var showRatingStats:Bool = true;

	#if WINDOW_CUSTOMIZATION
	/**
	 * Window darkmode.
	 */
	public var darkmodeEnabled:Bool = false;
	#end

	#if ASTRO_WATERMARKS
	/**
	 * Orbl's furry stuff, don't mind it.
	 */
	public var goober:Bool = false;
	#end

	/**
	 * Player Stats
	 */
	@:deprecated("Uhh,,, ima revamp this...")
	public var stats:Map<String, Dynamic> = ['Max Misses' => 0, 'Max Score' => 0];
}

@:access(funkin.backend.client.DiscordClient._checkClientID)
class ClientPrefs
{
	/**
	 * Current save data.	
	 */
	public static var data:SaveVariables = {};

	/**
	 * Default save data.	
	 */
	public static var defaultData:SaveVariables = {};

	/**
	 * Keyboard binds.
	 * Every key has two binds, add your key bind down here and then add your 
	 * control on options/ControlsSubState.hx and Controls.hx
	 */
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

	/**
	 * Gamepad binds.	
	 */
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

	/**
	 * Default keyboard keys.	
	 */
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	/**
	 * Default controller buttons.	
	 */
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	/**
	 * Reset all keys.	
	 */
	public static function resetKeys(controller:Null<Bool> = null) // Null = both, False = Keyboard, True = Controller
	{
		if (controller != true)
			for (key in keyBinds.keys())
				if (defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());

		if (controller != false)
			for (button in gamepadBinds.keys())
				if (defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
	}

	/**
	 * Clear all invalid keys
	 */
	public static function clearInvalidKeys(key:String):Void
	{
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while (keyBind != null && keyBind.contains(NONE))
			keyBind.remove(NONE);
		while (gamepadBind != null && gamepadBind.contains(NONE))
			gamepadBind.remove(NONE);
	}

	/**
	 * Load the default keys.	
	 */
	public static function loadDefaultKeys():Void
	{
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	/**
	 * Save settings
	 */
	public static function saveSettings():Void
	{
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		FlxG.save.flush();

		try
		{
			final save:FlxSave = new FlxSave();
			save.bind('controls_v2',
				CoolUtil.savePath); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
			save.data.keyboard = keyBinds; // now it saves :D
			save.data.gamepad = gamepadBinds;
			save.flush();
			FlxG.log.notice("Successfully saved settings.");
		}
		catch (e:Dynamic)
			FlxG.log.error("Failed to save settings.");
	}

	/**
	 * Load Prefs.
	 */
	public static function loadPreferences()
	{
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		#if (!html5 && !switch)
		FlxG.autoPause = ClientPrefs.data.autoPause;

		if (FlxG.save.data.framerate == null)
		{
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
		}
		#end
		if (data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

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

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if DISCORD_ALLOWED DiscordClient._checkClientID(); #end

		final controlsSave:FlxSave = new FlxSave();
		controlsSave.bind('controls_v2', CoolUtil.savePath);
		if (controlsSave != null)
		{
			if (controlsSave.data.keyboard != null)
			{
				final loadedControls:Map<String, Array<FlxKey>> = controlsSave.data.keyboard;
				for (control => keys in loadedControls)
					if (keyBinds.exists(control))
						keyBinds.set(control, keys);
			}
			if (controlsSave.data.gamepad != null)
			{
				final loadedControls:Map<String, Array<FlxGamepadInputID>> = controlsSave.data.gamepad; // haxe being weird
				for (control => keys in loadedControls)
					if (gamepadBinds.exists(control))
						gamepadBinds.set(control, keys);
			}
			reloadVolumeKeys();
		}

		reloadVolumeKeys();
	}

	/**
	 * Init ofc
	 */
	public static function init():Void
	{
		var is:Bool = false;
		try
		{
			loadPreferences();
			saveSettings();
			is = true;
		}
		catch (error:Dynamic)
			Logs.prefixedTrace('Error Loading Clientprefs, $error', 'ERROR, Clientprefs', RED);

		Logs.prefixedTrace('Loaded ClientPrefs : ${Std.string(is)}', 'User Preferences', GREEN);
		return;
	}

	/**
	 * Get gameplay setting
	 */
	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic
	{
		if (!customDefaultValue)
			defaultValue = defaultData.gameplaySettings.get(name);
		return (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	/**
	 * Reload volume keys.
	 */
	public static function reloadVolumeKeys():Void
	{
		Volume.muteKeys = keyBinds.get('volume_mute').copy();
		Volume.volumeDownKeys = keyBinds.get('volume_down').copy();
		Volume.volumeUpKeys = keyBinds.get('volume_up').copy();

		toggleVolumeKeys(true);
	}

	/**
	 * Toggle volume keys
	 */
	public static function toggleVolumeKeys(?toggle:Bool = true):Void
	{
		FlxG.sound.muteKeys = toggle ? Volume.muteKeys : [];
		FlxG.sound.volumeDownKeys = toggle ? Volume.volumeDownKeys : [];
		FlxG.sound.volumeUpKeys = toggle ? Volume.volumeUpKeys : [];
	}
}
