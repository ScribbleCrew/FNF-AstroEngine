package funkin.game.objects.scorebars;

// todo: adjust the strums to fit the v-slice style.
class VSliceScore extends UserInterface
{
	@:dox(hide) override function create():Void
	{
		super.create();

		scoreText = new FlxText(healthBar.bg.x + healthBar.bg.width - 190, healthBar.bg.y + 30, 0, '>;3c', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		game.shouldTweenScore = timeTxt.visible = timeBar.visible = false;
	}

	@:dox(hide) override function updateScore():Void
		scoreText.text = 'Score: {1}'.substitute([FlxStringUtil.formatMoney(PlayState.instance.songScore, false, true)]);
}
