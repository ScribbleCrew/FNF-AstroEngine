package funkin.backend.audio;

import lime.media.AudioManager;
import flixel.FlxState;
import flixel.sound.FlxSound;

@:dox(hide)
class AudioSwitchFix {
	@:noCompletion private static function onStateSwitch(state:FlxState):Void {
		#if windows
			if (Main.audioDisconnected) {
				var playingList:Array<PlayingSound> = [];
				for(sound in FlxG.sound.list) {
					if (sound.playing) {
						playingList.push({
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

				for(sound in playingList)
					sound.sound.play(sound.time);

				Main.audioDisconnected = false;
			}
		#end
	}

	public static function init() {
		#if windows
		WindowUtil.registerAudio();
		FlxG.signals.preStateCreate.add(onStateSwitch);
		#end
	}
}

typedef PlayingSound = {
	var sound:FlxSound;
	var time:Float;
}