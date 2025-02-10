package funkin.backend.system.initialization;
import flixel.input.keyboard.FlxKey;

/**
 * Random data stuff here.
 */
@:publicFields 
@:keep class Volume
{
	static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
}
