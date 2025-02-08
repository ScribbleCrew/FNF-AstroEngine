package funkin.game;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import funkin.game.FPS;

#if desktop
import funkin.backend.initialization.ALSoftConfig; // Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
#end


/**
 * No need to change anything here unless you know what your doin' :3c
 * If you want to add something that will run once the game has started, edit Init.hx
 *
 * You can pretty much ignore everything from here on - your code should go in your funkin.game.states
 */
class Main extends Sprite
{
	private static var _game:FlxGame;
	public static var fpsVar:FPS;

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new():Void
	{
		super();

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?evnt:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (Config.zoom == -1.0)
		{
			final ratioX:Float = stageWidth / Config.gameSize.width;
			final ratioY:Float = stageHeight / Config.gameSize.height;
			
			Config.zoom = Math.min(ratioX, ratioY);
			Config.gameSize.width = Math.ceil(stageWidth / Config.zoom);
			Config.gameSize.height = Math.ceil(stageHeight / Config.zoom);
		}

		_game = new FlxGame(Config.gameSize.width, Config.gameSize.height, Init, #if (flixel < "5.0.0") Config.zoom, #end Config.framerate, Config.framerate,
			Config.skipSplash, Config.startFullscreen);
		#if (FUNKIN_SOUNDTRAY || BASE_GAME_FILES)
		@:privateAccess
		_game._customSoundTray = funkin.backend.system.ui.FunkinSoundTray;
		#end
		addChild(_game);

		#if !mobile
		// FPS Stuff
		fpsVar = setupFPS();

		// idk, lol...
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end
	}

	#if !mobile
	// FPS Stuff
	private function setupFPS():FPS {
		final fpsVar:FPS = new FPS(10, 3, 0xFFFFFF);
		fpsVar.visible = false;
		fpsVar.offset.x += 25;
		fpsVar.offset.y += 5;
		addChild(fpsVar.bgSprite);
		addChild(fpsVar);

		return fpsVar;
	}
	#end

	// Audio Fix
	@:dox(hide) public static var audioDisconnected(default, set):Bool = false;
	@:noCompletion private static function set_audioDisconnected(value:Bool):Bool //oops
	{
		audioDisconnected = value;
		@:privateAccess AudioSwitchFix.onStateSwitch(FlxG.state);
		return audioDisconnected = value;
	}
}
