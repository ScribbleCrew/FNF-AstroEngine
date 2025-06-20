package funkin.game.objects.scorebars;

// todo: adjust the strums to fit the v-slice style.
@:dox(hide) class VSliceScore extends UserInterface
{
	override function create():Void
	{
		super.create();

		scoreText = new FlxText(healthBar.bg.x + healthBar.bg.width - 190, healthBar.bg.y + 30, 0, '>;3c', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.antialiasing = false;
		scoreText.setFormat(Constants.DEFAULT_FONT, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		game.shouldTweenScore = timeTxt.visible = timeBar.visible = false;
	}

	override function createPost() : Void
	{
		super.createPost();

		for (i in 0...4)
		{
			final playerStrum = game.playerStrums.members[i];
			playerStrum.x = (FlxG.width / 2 + Constants.CLASSIC_STRUMLINE_X_OFFSET) + ((Note.swagWidth) * i);
		}
	}

	override function updateScore():Void
		scoreText.text = 'Score: {1}'.substitute([FlxStringUtil.formatMoney(PlayState.instance.songScore, false, true)]);
}
