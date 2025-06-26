package huds;

import flixel.text.FlxText.FlxTextAlign;
using funkin.backend.utils.StringUtils;

class Psych extends funkin.backend.base.UserInterface
{
	override function create():Void
	{
		scoreText = new FunkinText(0, healthBar.y + 40, FlxG.width, "", 20, true);
		scoreText.scrollFactor.set();
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alignment = FlxTextAlign.CENTER;
		scoreText.alpha = 0;
		add(scoreText);
	}

	override function updateScore():Void
	{
		scoreText.text = 'Score: {1} | Misses: {2} | Rating: {3}'.substitute([game.songScore, game.songMisses, game.formattedRating]);
	}
}
