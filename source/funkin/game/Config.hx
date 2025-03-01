package funkin.game;

import haxe.ds.StringMap;

@:publicFields 
final class Config {
    static var gameSize:{width:Int,height:Int} = { width : 1280, height : 720 }; // WINDOW width & height.
	static var zoom:Float = -1.0; // Game Zoom.
	static final framerate:Int = 144; // Framerate.
	static final skipSplash:Bool = true; // If HaxeFlixel splash screen should be skipped.
	static final startFullscreen:Bool = false; // If the game should start in fullscreen mode.

	static final discordID:String = ''; // Custom Discord RPC ID here :3c
}