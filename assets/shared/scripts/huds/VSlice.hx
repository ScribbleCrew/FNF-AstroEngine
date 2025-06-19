package huds;

import flixel.util.FlxColor;
import funkin.backend.base.UserInterface;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextAlign;

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
		scoreText.setFormat(funkin.backend.utils.Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.RIGHT, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		game.shouldTweenScore = timeTxt.visible = timeBar.visible = false;
	}

	override function updateScore():Void
	{
		scoreText.text = 'Score: {1}'.substitute([FlxStringUtil.formatMoney(PlayState.instance.songScore, false, true)]);
	}
}
