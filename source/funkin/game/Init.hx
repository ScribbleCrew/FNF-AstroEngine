package funkin.game;

import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import funkin.backend.utils.Paths;
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
#end

class Init extends flixel.FlxState
{
	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		WindowUtil.resetTitle();

		FlxG.save.bind('funkin', funkin.backend.CoolUtil.getSavePath());

		#if LUA_ALLOWED Mods.pushGlobalMods(); #end

		Mods.loadTopMod();

		Controls.instance = new Controls();

		Logs.init();
		funkin.backend.Highscore.init();
		funkin.backend.utils.ClientPrefs.init();
		MusicBeatState.init();
		init();

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(CallbackHandler.call)); #end

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		#if DISCORD_ALLOWED DiscordClient.prepare(); #end

		#if VIDEOS_ALLOWED hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end); #end

		#if CRASH_HANDLER initCrashHandler(); #end

		#if SHADERS_ALLOWED fragFix(); #end

		funkin.game.objects.Alphabet.AlphaCharacter.loadAlphabetData();

		super.create();

		#if WATERMARK owoWatermark(); #end

		// Extra stuff goes here :3

		FlxG.switchState(new TitleState());
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
			funkin.game.states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
	}

	#if CRASH_HANDLER
	private function initCrashHandler()
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.main);
	#end

	#if SHADERS_ALLOWED
	private function fragFix()
	{
		FlxG.signals.gameResized.add(function(w, h)
		{
			if (FlxG.cameras != null)
				for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	private static function resetSpriteCache(sprite:openfl.display.Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
	#end

	#if WATERMARK
	public static var watermark:openfl.text.TextField;

	private function owoWatermark():Void
	{
		// uhh tester text lmao
		final watermarkText:String = '${OsAPI.username}\n${HashUtils.hash(OsAPI.username, MD5)}';

		final format:openfl.text.TextFormat = new openfl.text.TextFormat("assets/fonts/OswaldMedium.ttf", 50, FlxColor.WHITE);
		format.align = openfl.text.TextFormatAlign.CENTER;

		watermark = new openfl.text.TextField();
		watermark.defaultTextFormat = format;
		watermark.text = watermarkText;
		watermark.alpha = .55;
		watermark.width = FlxG.width;
		watermark.height = FlxG.height;
		watermark.selectable = false;

		watermark.y = (FlxG.height - watermark.textHeight) / 2;

		Lib.current.addChild(watermark);
	}
	#end
}

class Volume
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
}

class Logs // Modded trace func
{
	private static final fembois:String = "[Astro System]"; // prefix i guess

	public static function init():Void
	{
		haxe.Log.trace = __customTrace;
		trace('Finished Setting up custom trace.');
	}

	@:noCompletion private static function __customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void
	{
		final nerddd = infos.fileName + ":" + infos.lineNumber;
		if (infos != null && infos.customParams != null)
		{
			var extra:String = "";
			for (v in infos.customParams)
				extra += ", " + v;
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log('$fembois: ${v + extra} : $nerddd');
			#elseif sys
			Sys.println('$fembois: ${v + extra} : $nerddd');
			#end
		}
		else
		{
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log('$fembois: $v : $nerddd');
			#elseif sys
			Sys.println('$fembois: $v : $nerddd');
			#end
		}
	}
}
