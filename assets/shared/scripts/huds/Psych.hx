package huds;

import flixel.util.FlxColor;
import funkin.backend.base.UserInterface;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextAlign;

import funkin.backend.utils.Paths; // substitute function

using funkin.backend.utils.StringUtils;

class Psych extends UserInterface
{
	override function create():Void
	{
        super.create();

		scoreText = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 20, FlxColor.WHITE, FlxTextAlign.CENTER, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);
	}

	override function updateScore():Void
	{
		scoreText.text = 'Score: {1} | Misses: {2} | Rating: {3}'.substitute([
			game.songScore,
			game.songMisses,
			game.formattedRating
		]);
	}
}
