package funkin.backend.audio;

import lime.media.AudioManager;
import flixel.FlxState;
import flixel.sound.FlxSound;

@:dox(hide)
class AudioSwitchFix {
	@:noCompletion static function onStateSwitch(state:FlxState):Void {
		#if windows
			if (Main.audioDisconnected) {
				var playingList:Array<PlayingSound> = [];
				for(e in FlxG.sound.list) {
					if (e.playing) {
						playingList.push({
							sound: e,
							time: e.time
						});
						e.stop();
					}
				}
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				AudioManager.shutdown();
				AudioManager.init();

				for(e in playingList) {
					e.sound.play(e.time);
				}

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