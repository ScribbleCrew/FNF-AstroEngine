package funkin.game;

import funkin.backend.utils.Paths;
import funkin.backend.system.initialization.*;

// __init__ imports
#if desktop
import funkin.backend.system.initialization.TemporaryFolder;

/**
 * Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
 */
import funkin.backend.system.initialization.ALSoftConfig;
#end

/**
 * very simple initialization state (WARNING: MUST BE LOADED BEFORE ANYTHING ELSE!!!)
 * i just like having a separate file for initializing stuff, instead of throwing it all 
 * into Main.hx.
 */
class Init extends flixel.FlxState
{
	#if WATERMARK public static var watermark:Watermark; #end

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		WindowUtil.title = '';

		FlxG.save.bind('funkin', funkin.backend.CoolUtil.getSavePath());

		ClientPrefs.loadDefaultKeys();

		#if mobile
		// Credits to MAJigsaw77 for this awesome piece of code. >:]c
		Sys.setCwd(#if android Path.addTrailingSlash(Context.getExternalFilesDir()) #elseif ios lime.system.System.applicationStorageDirectory #end);
		#end

		#if LUA_ALLOWED Mods.pushGlobalMods(); #end

		Mods.loadTopMod();

		Controls.instance = new Controls();

		#if MODIFIED_LOGS Logs.init(); #end
		funkin.backend.Highscore.init();
		funkin.backend.utils.ClientPrefs.init();
		this.init();

		#if desktop funkin.backend.system.initialization.TemporaryFolder.init(); #end
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(CallbackHandler.call)); #end
		#if CRASH_HANDLER CrashLogger.init(); #end
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		#if DISCORD_ALLOWED DiscordClient.prepare(); #end
		#if SHADERS_ALLOWED ShaderCoordsFix.init(); #end
		#if windows AudioSwitchFix.init(); #end
		#if HSCRIPT_ALLOWED IrisConfig.init(); #end
		GlobalScript.init();

		funkin.game.objects.Alphabet.AlphaCharacter.loadAlphabetData();

		super.create();

		#if WATERMARK
		watermark = new Watermark();
		openfl.Lib.current.addChild(watermark);
		#end

		#if VIDEOS_ALLOWED
		final loadingText:FlxText = new FlxText();
		loadingText.setFormat(Paths.font("Minecraft.ttf"), 24, FlxColor.WHITE);
		loadingText.text = "Loading...";
		loadingText.screenCenter();
		add(loadingText);

		hxvlc.util.Handle.initAsync(#if (hxvlc >= "1.8.0") ['--no-lua'] #end, _ ->
		{
			Logs.prefixedTrace(_ ? "LibVLC initialized" : "Error on initializing LibVLC!",'hxvlc',YELLOW);
			clearState();
		});
		#else
		clearState();
		#end

		// Extra stuff goes here :3
	}

	static function clearState():Void
	{
		#if windows WindowUtil.darkmode = ClientPrefs.data.darkmodeEnabled; #end
		#if !mobile
		Main.framerateCounter.visible = ClientPrefs.data.showFPS;
		Main.framerateCounter.alpha = ClientPrefs.data.fpsCounterAlpha;
		#end
		FlxG.switchState(new TitleState());
		Logs.prefix = '';
	}

	private function init():Void
	{
		FlxG.fixedTimestep = #if html5 FlxG.mouse.visible = #end
		false;
		FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.game.focusLostFramerate = 30;

		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		if (FlxG.save.data.weekCompleted != null)
			Week.weekCompleted = FlxG.save.data.weekCompleted;
	}
}
