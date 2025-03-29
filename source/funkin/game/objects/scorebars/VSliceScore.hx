package funkin.game.objects.scorebars;

class VSliceScore extends DefaultHUD
{
	var scoreText:FlxText;

	override function create():Void
	{
		super.create();

		scoreText = new FlxText(healthBar.bg.x + healthBar.bg.width - 190, healthBar.bg.y + 30, 0, '>;3c', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		timeTxt.visible = timeBar.visible = false;
	}

	override function updateScore():Void
	{
		final moneyScore:String = flixel.util.FlxStringUtil.formatMoney(PlayState.instance.songScore, false, true);
		scoreText.text = 'Score: {1}'.replaceAll([moneyScore]);
	}
}
