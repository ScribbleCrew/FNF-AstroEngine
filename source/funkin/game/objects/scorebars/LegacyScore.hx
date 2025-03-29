// TODO legacy score engine score bar stuff here.

package funkin.game.objects.scorebars;

using funkin.backend.utils.StringUtils;
class PsychScore extends BaseScorebar
{
	private var scoreText:FlxText;

	override function create()
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

	override function updateScore():Void
	{
		var str:String = PlayState.instance.ratingName;
		if(PlayState.instance.totalPlayed != 0)
		{
			final percent:Float = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);
			str += ' (${percent}%) - ' + PlayState.instance.ratingFC;
		}

		final tempScore = StringUtils.replaceAll('Score: {1} | Misses: {2} | Rating: {3}', [PlayState.instance.songScore, PlayState.instance.songMisses, str]);
		scoreText.text = tempScore;
	}
}
