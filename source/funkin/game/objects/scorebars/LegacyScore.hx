// TODO legacy score engine score bar stuff here.

package funkin.game.objects.scorebars;

using funkin.backend.utils.StringUtils;
class PsychScore extends BaseScorebar
{
	var scoreText:FlxText;

	override function create():Void
	{
		super.create();

		//game.baseUI.defaultFont = Constants.DEFAULT_FONT;

		scoreText = new FlxText(0, defaultPos.y + 40, FlxG.width, "", 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);
	}

	function fixedRating():String {
		var formattedRating:String = PlayState.instance.ratingName;
		if(PlayState.instance.totalPlayed != 0)
			formattedRating += ' (${CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2)}%) - ' + PlayState.instance.ratingFC;
		return formattedRating;
	}

	override function updateScore():Void
		scoreText.text = 'Score: {1} | Misses: {2} | Rating: {3}'.substitute([PlayState.instance.songScore, PlayState.instance.songMisses, fixedRating()]);

}
