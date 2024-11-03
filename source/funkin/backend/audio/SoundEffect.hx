package funkin.backend.audio;

/**
 *	This class is used to add sound effects to different FlxSounds.
 *	TODO: let lua be able to interact with this.
 *
 *	@author YourFriendOrbl
 */
@:access(flixel.sound.FlxSound)
class SoundEffect
{
	/**
	 *	Sound thing idk.
	 */
	private static var _sound(default, null):FlxSound = new FlxSound();

	/**
	 *	Echo sound effect
	 */
	public static function echoEffect(sound:FlxSound):Void
	{
		/**
		 *	Load the sound.
		 */
		_sound.loadEmbedded(sound._sound);

		/**
		 *	Set the volume by dividing sound.volume by 2.
		 */
		_sound.volume = (sound.volume / 2);

		/**
		 *	Set the stereo panning to -0.5.
		 */
		_sound.pan = -.5;

		/**
		 *	After 100 milseconds the auto effect will start.
		 */
		new flixel.util.FlxTimer().start(.1, (tmr) -> _sound.play());
	}
}
