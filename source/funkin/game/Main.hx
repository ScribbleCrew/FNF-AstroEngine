package funkin.game;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.StageScaleMode;
import funkin.game.FPS;

#if desktop
// Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
import funkin.backend.initialization.ALSoftConfig;
#end

/**
 * No need to change anything here unless you know what your doin' :3c
 * If you want to add something that will run once the game has started, edit Init.hx
 *
 * You can pretty much ignore everything from here on - your code should go in your funkin.game.states
 */
#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end
#if windows
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end
class Main extends openfl.display.Sprite
{
	public static var fpsVar:FPS;

	private static var _game:FlxGame;

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new():Void
	{
		super();
		
		#if windows
		// DPI Scaling fix for windows 
		// this shouldn't be needed for other systems
		// Credit to YoshiCrafter29 for finding this function
		untyped __cpp__("SetProcessDPIAware();");
		#end
	
		_game = new FlxGame(Config.gameSize.width, Config.gameSize.height, Init, #if (flixel < "5.0.0") Config.zoom, #end Config.framerate, Config.framerate,
			Config.skipSplash, Config.startFullscreen);
		#if (FUNKIN_SOUNDTRAY || BASE_GAME_FILES)
		@:privateAccess
		_game._customSoundTray = funkin.backend.system.ui.FunkinSoundTray;
		#end
		addChild(_game);

		#if !mobile
		fpsVar = setupFPS();

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end

		#if linux
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));
		#end
	}

	#if !mobile
	// FPS Stuff
	private function setupFPS():FPS {
		final fpsVar:FPS = new FPS(10, 3, 0xFFFFFF);
		fpsVar.visible = false;
		fpsVar.bgOffset.x += 25;
		fpsVar.bgOffset.y += 5;
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
