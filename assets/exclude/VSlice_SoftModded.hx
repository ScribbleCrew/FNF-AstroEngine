package huds;

import flixel.util.FlxColor;
import funkin.backend.base.UserInterface;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextAlign;

import funkin.backend.utils.Paths;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.game.objects.notes.Note;

using funkin.backend.utils.StringUtils;

class VSlice extends UserInterface
{
	override function create():Void
	{
		super.create();

		scoreText = new FlxText(healthBar.bg.x + healthBar.bg.width - 190, healthBar.bg.y + 30, 0, '>;3c', 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
        scoreText.antialiasing = false;// ???
		scoreText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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

	override function updateScore():Void{
		scoreText.text = 'Score: {1}'.substitute([FlxStringUtil.formatMoney(game.songScore, false, true)]);}
}
