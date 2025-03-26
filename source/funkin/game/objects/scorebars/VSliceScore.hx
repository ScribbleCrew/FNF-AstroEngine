package funkin.game.objects.scorebars;

class VSliceScore extends BaseScorebar
{
	var scoreText:FlxText;

	override function create() : Void
	{		
		super.create();

		scoreText = new FlxText(baseUI.healthBar.bg.x + baseUI.healthBar.bg.width - 190, baseUI.healthBar.bg.y + 30, 0, '>;3c', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		game.baseUI.timeTxt.visible = game.baseUI.timeBar.visible = false;
	}

	override function updateScore() : Void
		if (scoreText!=null) scoreText.text = 'Score: ' + flixel.util.FlxStringUtil.formatMoney(game.instance.songScore, false, true);
}
