package funkin.game.objects.scorebars;

import flixel.util.FlxStringUtil;

class VSliceScore extends BaseScorebar
{
	private var scoreText:FlxText;

	override function create()
	{
		super.create();
		
//		game.timeTxt.visible = game.timeBar.visible = false;

		var defaultPosButBetter = game.healthBar.bg;

		scoreText = new FlxText(defaultPosButBetter.x + defaultPosButBetter.width - 190, defaultPosButBetter.y + 30, 0, '', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideFullHUD;
		scoreText.alpha = 0;
		scoreText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);
	}

	override function updateScore()
	{
		super.updateScore();
		scoreText.text = 'Score: ' + FlxStringUtil.formatMoney(PlayState.instance.songScore, false, true);
	}
}
