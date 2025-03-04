package funkin.game;

import flixel.FlxG;
import flixel.FlxGame;

import funkin.game.FPS;

import openfl.Lib;
import openfl.display.MovieClip;
import openfl.display.StageScaleMode;

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
@:access(flixel.FlxGame._customSoundTray)
@:access(funkin.backend.audio.AudioSwitchFix.onStateSwitch)
class Main extends flixel.FlxGame
{
	/**	
	 * Main instance.
	 */
	public static var instance(default, null):Main;

	/**	
	 * Framerate variable.
	 * used to handle my new sexy fps code.
	 */
	@:isVar
	public static var fpsVar(get, null):FPS;
	@:dox(hide) inline static function get_fpsVar():FPS
		return #if !mobile fpsVar #else null #end;

	/**
	 * The Application screen, all this just really
	 * does is shorten `Lib.current`.	
	 */
	public static var appScreen(get, never):MovieClip;
	@:dox(hide) inline static function get_appScreen():MovieClip
		return Lib.current;

	public static function main():Void
	{
		/** 
		 * Set the FlxSprite's default antialiasing to true.
		 */
		FlxSprite.defaultAntialiasing = true;

		/** 
		 * Init the cool events.
		 */
		funkin.backend.system.initialization.CoolEvents.init();

		/** 
		 * Make a `Main` instance
		 * i wanna see if dis works.
		 */
		Type.createInstance(Main, []);
	}

	public function new():Void
	{
		@:bypassAccessor instance = this;

		#if ALLOW_DPI_FIX
		/** 
		 * DPI Scaling fix for windows, this shouldn't be needed for other systems
		 * Credit to YoshiCrafter29 for finding this function
		 */
		untyped __cpp__("SetProcessDPIAware()");

		/** 
		 * Allows you to move the window if the process if not responsive.
		 */
		untyped __cpp__("DisableProcessWindowsGhosting()");

		/** 
		 * Gets the display.
		 */
		final display:lime.system.Display = lime.system.System.getDisplay(Lib.application.window.display.id);

		/** 
		 * Make sure the display doesn't equal null.
		 */
		if (display != null)
		{
			/** 
			 * The api scale of the display.
			 */
			final dpiScale:Float = display.dpi / 96;
			Application.current.window.width = Std.int(Config.gameSize.width * dpiScale);
			Application.current.window.height = Std.int(Config.gameSize.height * dpiScale);
			
			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		}
		#end

		super(Config.gameSize.width, Config.gameSize.height, Init, #if (flixel < "5.0.0") Config.zoom, #end Config.framerate, Config.framerate, #if SKIP_SPLASH_SCREEN true #else Config.skipSplash #end, Config.startFullscreen);

		#if (FLX_SOUND_TRAY && (FUNKIN_SOUNDTRAY || BASE_GAME_FILES)) // yeah...
		_customSoundTray = funkin.backend.system.ui.FunkinSoundTray;
		#end

		appScreen.stage.addChild(this);

		#if !mobile
		fpsVar = FPS.make();
		appScreen.stage.addChild(fpsVar.bgSprite);
		appScreen.stage.addChild(fpsVar);

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end

		#if linux Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png")); #end
	}

	// Audio Fix
	@:dox(hide) public static var audioDisconnected(default, set):Bool = false;
	@:dox(hide) inline static function set_audioDisconnected(value:Bool):Bool // oops
	{
		audioDisconnected = value;
		AudioSwitchFix.onStateSwitch(FlxG.state);
		return value;
	}
}
