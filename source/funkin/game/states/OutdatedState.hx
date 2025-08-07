package funkin.game.states;

#if CHECK_FOR_UPDATES
import funkin.backend.data.EngineData;
import funkin.backend.CoolUtil;

class OutdatedState extends MusicBeatState
{
	public static var _left:Bool = false;

	final text:String = "Sup bro, looks like you're running an   \n
			outdated version of Astro Engine ["
		+ EngineData.VERSION
		+ "],\n
			please update to "
		+ funkin.game.states.TitleState.updateVersion
		+ "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Engine!\n>;3c";

			
	var warnText:FlxText;
	
	override function create():Void
	{
		#if desktop
		Windows.title = ('%{GAME_TITLE} - Outdated');
		FlxG.mouse.visible = false;
		#end

		super.create();

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		warnText = new FlxText(0, 0, FlxG.width, text, 32);
		warnText.setFormat(Constants.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float):Void
	{
		if (!_left)
		{
			if (controls.ACCEPT)
			{
				_left = true;
				CoolUtil.browserLoad('${EngineData.REPOSITORY}/releases');
			}
			else if (controls.BACK)
				_left = true;

			if (_left)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {onComplete: (twn:FlxTween) -> MusicBeatState.switchState(new funkin.game.states.MainMenuState())});
			}
		}

		super.update(elapsed);
	}
}
#end
