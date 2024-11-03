package funkin.backend.audio;

class SoundEffect
{
	public static function echoEffect(sound:FlxSound)
	{
		var echoSound:FlxSound = new FlxSound();
		@:privateAccess echoSound.loadEmbedded(sound._sound);
		echoSound.volume = (sound.volume / 2);
		echoSound.pan = -.5;

		new flixel.util.FlxTimer().start(.1, (tmr) -> echoSound.play());
	}
}