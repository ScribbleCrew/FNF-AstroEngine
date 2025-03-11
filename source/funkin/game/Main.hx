package funkin.game;

// imports
import openfl.Lib;
import funkin.game.FPS;
import openfl.display.MovieClip;

/**
 * Hello traveler, What brings you here?
 *
 * No need to change anything here unless you know what your doin' :3c
 * If you want to add something that will run once the game has started, edit Init.hx
 * 
 * You can pretty much ignore everything from here on - your state code should go in funkin.game.states
 */
#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
#if windows
@:buildXml('<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);')
#end
@:access(flixel.FlxGame._customSoundTray)
@:access(funkin.backend.audio.AudioSwitchFix.onStateSwitch)
class Main extends flixel.FlxGame
{
	/**	
	 * An instance of Main. Mainly used to access non-static variables & methods.
	 * I genuinely don't know why this should be public for soft modding, buttt(lol) ehh. 🦦
	 *
	 * @returns An instance of Main.
	 */
	public static var instance(default, null):Main;

	/**	
	 * Framerate variable.
	 * used to handle my new sexy fps code.
	 */
	@:isVar
	public static var framerateCounter(get, null):FPS;
	@:dox(hide) inline static function get_framerateCounter():FPS
		return #if !mobile framerateCounter #else null #end;
 

	/**
	 * Application screen, all this just really does is shorten `Lib.current`.	
	 * I love get set variables, they're so cool!
	 *
	 * @returns `Lib.current`.
	 */
	public static var applicationScreen(get, never):MovieClip;
	@:dox(hide) inline static function get_applicationScreen():MovieClip
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
		 * Create a new instance of Main.
		 */
		new Main();
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
			 * Screen's DPI Scale, expressed as an float.
			 */
			final dpiScale:Float = display.dpi / 96;

			/**
			* Update the current window's width and height.	
			*/
			Application.current.window.width = Std.int(Config.gameSize.width * dpiScale);
			Application.current.window.height = Std.int(Config.gameSize.height * dpiScale);
			
			/**
			* Update the current window's position (XY).	
			*/
			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		}
		#end

		super(Config.gameSize.width, Config.gameSize.height, Init, #if (flixel < "5.0.0") Config.zoom, #end Config.framerate, Config.framerate, #if SKIP_SPLASH_SCREEN true #else Config.skipSplash #end, Config.startFullscreen);

		#if (FLX_SOUND_TRAY && (FUNKIN_SOUNDTRAY || BASE_GAME_FILES)) // yeah...
		/**
		* Custom FlxSound Tray, mainly here to give that v-slice feeling.	
		*/
		_customSoundTray = funkin.backend.system.ui.FunkinSoundTray;
		#end

		/**
		* Add the game.	
		*/
		applicationScreen.stage.addChild(this);

		#if !mobile
		/**
		* Create and setup the framerate counter.
		*/
		framerateCounter = FPS.make();
		applicationScreen.stage.addChild(framerateCounter.bgSprite);
		applicationScreen.stage.addChild(framerateCounter);

		/**
		* Change the stage's align and scale mode.
		*/
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
		#end

		#if linux 
		/**
		* I Don't actually know what his does.	
		*/
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png")); 
		#end
	}

	/**
	* Audio disconnected fix.	
	*/
	@:dox(hide) static var _audioDisconnected(default, set):Bool = false;
	@:dox(hide) inline static function set__audioDisconnected(value:Bool):Bool // oops
	{
		_audioDisconnected = value;
		AudioSwitchFix.onStateSwitch(FlxG.state);// does this even work.
		return value;
	}
}
