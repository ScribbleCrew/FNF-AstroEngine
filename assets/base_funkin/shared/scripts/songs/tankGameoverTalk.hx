package songs;

import funkin.game.states.substates.GameOverSubstate;

var gameover(get, never):GameOverSubstate;
function get_gameover():GameOverSubstate
	return GameOverSubstate.instance;

function onLoopFinish() : Void
{
	if (!isDead && GameOverSubstate.instance != null)
		return;

	if (!gameover.isEnding && gameover.justPlayedLoop && PlayState.SONG.stage == 'tank')
	{
		gameover.coolStartDeath(0.2);

		final soundName:String = 'jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, ClientPrefs.data.cursing ? [1, 3, 8, 13, 17, 21] : []);
		FlxG.sound.play(Paths.sound(soundName), 1, false, null, true, function()
		{
			if (!gameover.isEnding)
				FlxG.sound.music.fadeIn(0.2, 1, 4);
		});
		return Function_Stop;
	}
}
