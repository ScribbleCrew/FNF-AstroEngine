package funkin.game.states;

import funkin.backend.data.EngineData;
import funkin.backend.CoolUtil;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width, "Sup bro, looks like you're running an   \n
			outdated version of Astro Engine ["
			+ EngineData.engineData.coreVersion
			+ "],\n
			please update to "
			+ funkin.game.states.TitleState.updateVersion
			+ "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Engine!", 32);
		warnText.setFormat(Constants.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (controls.ACCEPT)
			{
				leftState = true;
				CoolUtil.browserLoad('${EngineData.engineData.repository}/releases');
			}
			else if (controls.BACK)
			{
				leftState = true;
			}

			if (leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new funkin.game.states.MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
