package funkin.game;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import funkin.backend.utils.Paths;

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

		#if WATERMARK owoWatermark(); #end

		funkin.game.objects.Alphabet.AlphaCharacter.loadAlphabetData();

		super.create();

		// Extra stuff goes here :3

		FlxG.switchState(new TitleState());
	}

	private function init():Void
	{
		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		if (FlxG.save.data.weekCompleted != null)
			funkin.game.states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
	}

	#if WATERMARK
	private function owoWatermark():Void
	{
		// uhh tester text lmao
		final owoTxt:TextField = new TextField();
		owoTxt.defaultTextFormat = new TextFormat("assets/fonts/OswaldMedium.ttf", 100, FlxColor.WHITE);
		owoTxt.text = 'BETA BUILD OF ASTRO ENGINE';
		owoTxt.alpha = .4;
		owoTxt.width = Lib.current.stage.stageWidth;
		owoTxt.height = Lib.current.stage.stageHeight;
		owoTxt.x = (Lib.current.stage.stageWidth - owoTxt.width) / 2;
		owoTxt.y = (Lib.current.stage.stageHeight - owoTxt.height) / 2;
		owoTxt.selectable = false;

		Lib.current.addChild(owoTxt);
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
	private static final fuckbaby:String = "[Astro System]"; // prefix i guess

	public static function init():Void
	{
		haxe.Log.trace = __customTrace;
		trace('Finished Setting up custom trace');
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
				(untyped console).log('$fuckbaby: ${v + extra} : $nerddd');
			#elseif sys
			Sys.println('$fuckbaby: ${v + extra} : $nerddd');
			#end
		}
		else
		{
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log('$fuckbaby: $v : $nerddd');
			#elseif sys
			Sys.println('$fuckbaby: $v : $nerddd');
			#end
		}
	}
}
