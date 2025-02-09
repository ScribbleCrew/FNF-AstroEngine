package funkin.game;

import flixel.input.keyboard.FlxKey;
import funkin.backend.utils.Paths;
import funkin.backend.initialization.*;

/**
 * Credits:
 * MAJigsaw77 - Og author of line 23.
 */
class Init extends flixel.FlxState
{
	#if WATERMARK
	public static var watermark:Watermark; 
	#end

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		WindowUtil.title = '';

		FlxG.save.bind('funkin', funkin.backend.CoolUtil.getSavePath());

		ClientPrefs.loadDefaultKeys();  
		#if (android || ios) Sys.setCwd(#if android Path.addTrailingSlash(Context.getExternalFilesDir()) #elseif ios lime.system.System.applicationStorageDirectory #end); #end

		#if LUA_ALLOWED Mods.pushGlobalMods(); #end

		Mods.loadTopMod();

		Controls.instance = new Controls();

		Logs.init();
		funkin.backend.Highscore.init();
		funkin.backend.utils.ClientPrefs.init();
		this.init();

		this.initFileThread();

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(CallbackHandler.call)); #end
		#if CRASH_HANDLER openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR,
			CrashHandler.main); #end
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		#if DISCORD_ALLOWED DiscordClient.prepare(); #end
		#if SHADERS_ALLOWED fragFix(); #end
		#if windows AudioSwitchFix.init(); #end

		funkin.game.objects.Alphabet.AlphaCharacter.loadAlphabetData();

		super.create();

		#if WATERMARK
		watermark = new Watermark();
		openfl.Lib.current.addChild(watermark);
		#end

		#if HSCRIPT_ALLOWED
		function laFunc(x, ?pos:haxe.PosInfos)
		{
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null)
				newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '') + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			return msgInfo;
		}

		Iris.warn = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(WARN, x, pos);
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: ${laFunc(x, pos)}', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(ERROR, x, pos);
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: ${laFunc(x, pos)}', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(FATAL, x, pos);
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: ${laFunc(x, pos)}', 0xFFBB0000);
		}
		#end

		#if VIDEOS_ALLOWED
		final loadingText:FlxText = new FlxText();
		loadingText.setFormat(Paths.font("Minecraft.ttf"), 24, FlxColor.WHITE);
		loadingText.text = "Loading...";
		loadingText.screenCenter();
		add(loadingText);

		hxvlc.util.Handle.initAsync(#if (hxvlc >= "1.8.0") ['--no-lua'] #end, _ ->
		{
			trace(_ ? "LibVLC initialized" : "Error on initializing LibVLC!");
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
		Main.fpsVar.visible = ClientPrefs.data.showFPS;
		Main.fpsVar.alpha = ClientPrefs.data.fpsCounterAlpha;
		#end
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
					if (daFile.main != null)
						daFile.main();
					if (daFile.__init__ != null)
						daFile.__init__();
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
			Week.weekCompleted = FlxG.save.data.weekCompleted;
	}

	#if SHADERS_ALLOWED
	private function fragFix():Void
	{
		function resetSpriteCache(sprite:openfl.display.Sprite):Void
		{
			@:privateAccess {
				sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
			}
		}

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
