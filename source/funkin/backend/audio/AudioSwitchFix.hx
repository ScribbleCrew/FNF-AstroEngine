package funkin.backend.audio;

import lime.media.AudioManager;
import flixel.FlxState;
import flixel.sound.FlxSound;

@:dox(hide)
@:access(funkin.game.Main._audioDisconnected)
class AudioSwitchFix
{
	@:noCompletion static function onStateSwitch(state:FlxState):Void
	{
		#if windows
		if (Main._audioDisconnected)
		{
			var allPlayingAudios:Array<
				{
					var sound:FlxSound;
					var time:Float;
				}> = [];
			for (sound in FlxG.sound.list)
			{
				if (sound.playing)
				{
					allPlayingAudios.push({
						sound: sound,
						time: sound.time
					});
					sound.stop();
				}
			}
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			AudioManager.shutdown();
			AudioManager.init();

			new FlxTimer().start(.1, (tmr:FlxTimer) ->
			{
				for (sound in allPlayingAudios)
					sound.sound.play(sound.time);

				Main._audioDisconnected = false;
			});
		}
		#end
	}

	public static function init():Void
	{
		#if windows
		WindowUtil.registerAudio();
		FlxG.signals.preStateCreate.add(onStateSwitch);
		#end
	}
}
