package funkin.game.objects.scorebars;

class VSliceScore extends BaseScorebar
{
	private var scoreText:FlxText;

	override function create() : Void
	{	
		final healthBarPosition:Bar = game.baseUI.healthBar.bg;
		scoreText = new FlxText(healthBarPosition.x + healthBarPosition.width - 190, healthBarPosition.y + 30, 0, '>;3c', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		super.create();

		game.baseUI.timeTxt.visible = game.baseUI.timeBar.visible = false;
	}

	override function updateScore() : Void
		scoreText.text = 'Score: ' + flixel.util.FlxStringUtil.formatMoney(game.instance.songScore, false, true);
}
