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
		WindowUtil.title = '';

		FlxG.save.bind('funkin', funkin.backend.CoolUtil.getSavePath());

		ClientPrefs.loadDefaultKeys();

		#if LUA_ALLOWED Mods.pushGlobalMods(); #end

		Mods.loadTopMod();

		Controls.instance = new Controls();

		Logs.init();
		funkin.backend.Highscore.init();
		funkin.backend.utils.ClientPrefs.init();
		this.init();

		this.initFileThread();

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(CallbackHandler.call)); #end

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		#if DISCORD_ALLOWED DiscordClient.prepare(); #end

		#if CRASH_HANDLER initCrashHandler(); #end

		#if SHADERS_ALLOWED fragFix(); #end

		#if windows AudioSwitchFix.init(); #end

		funkin.game.objects.Alphabet.AlphaCharacter.loadAlphabetData();

		super.create();

		#if WATERMARK owoWatermark(); #end

		#if VIDEOS_ALLOWED
		final loadingText:FlxText = new FlxText();
		loadingText.setFormat(Paths.font("Minecraft.ttf"), 24, FlxColor.WHITE);
		loadingText.text = "Loading...";
		loadingText.screenCenter();
		add(loadingText);

		hxvlc.util.Handle.initAsync(#if (hxvlc >= "1.8.0") ['--no-lua'] #end, _ -> {
			trace(_ ? "LibVLC initialized" : "Error on initializing LibVLC!");
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
			clearState();
		});
		#else
		clearState();
		#end
		
		// Extra stuff goes here :3
	}

	static function clearState() : Void {
		trace('Leaving state');
		FlxG.switchState(new TitleState());
	}

	#if THREADING_ALLOWED
	static var mutex:Mutex = new Mutex();
	#end
	static var threadedInitialization:Int = 0;

	private function initFileThread():Void
	{
		final daInitFiles:Array<Dynamic> = [funkin.backend.initialization.TemporaryFolder];

		for (file in daInitFiles)
		{
			#if THREADING_ALLOWED
			Thread.create(() -> {
				mutex.acquire();
			#end
				try
				{
					final daFile:Dynamic = cast file;
					daFile.main();
				}
				catch (e:Dynamic)
				{
					trace('ERROR! : $e');
				}
				#if THREADING_ALLOWED
				mutex.release();
				#end
				threadedInitialization++;
			#if THREADING_ALLOWED
			});
			#end
		}
	}

	private function init():Void
	{
		trace(OsAPI.osInfo + ' ' + OsAPI.osVersion);

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
	private function initCrashHandler():Void
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.main);
	#end

	#if SHADERS_ALLOWED
	private function fragFix():Void
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
	public static function init():Void
	{
		haxe.Log.trace = __customTrace;
		trace('Finished Setting up custom trace.');
	}

	@:noCompletion private static function __customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void
	{
		var extra:String = "";
		if (infos != null && infos.customParams != null)
			for (param in infos.customParams)
				extra += ", " + param;

		final logThing:String = '${Constants.LOGS_PREFIX}: ${v + (extra == "" ? '' : extra)} : ${infos.fileName + ":" + infos.lineNumber}';

		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(logThing);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(logThing));
		#elseif sys
		Sys.println(logThing);
		#else
		throw new haxe.exceptions.NotImplementedException();
		#end
	}
}
