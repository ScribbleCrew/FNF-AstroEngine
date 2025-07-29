package huds;

// this ui is so messy :P
// don't use this as a ref
import funkin.backend.Highscore;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import funkin.backend.base.UserInterface;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextAlign;
import funkin.backend.utils.Paths;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.backend.data.EngineData;
import funkin.backend.Difficulty;

using flixel.util.FlxSpriteUtil;
using funkin.backend.utils.StringUtils; // for the substitute function
using funkin.backend.utils.ObjectUtils;
using StringTools;

class Astro extends UserInterface
{
	final CONST_FONT:String = Paths.font("PhantomMuff.ttf");

	var watermark:FlxText;
	var songLeft:FlxText;
	var versionTxtSmth:FlxText;

	/**
	 * Stores HUD Objects in a Group	
	 */
	public var uiBackgroundGroup:FlxGroup;

	function setupBGGroup()
	{
		game.insert(game.members.indexOf(game.uiGroup), uiBackgroundGroup = new FlxGroup()); // brah
		uiBackgroundGroup.visible = !ClientPrefs.data.downScroll && !ClientPrefs.data.hideHud; // maybe fix downscrollin'???
		uiBackgroundGroup.cameras = [game.camHUD];
	}

	override function create():Void
	{
		setupBGGroup();

		scoreText = new FlxText(0, healthBar.y + 36, FlxG.width, "erm, owo???", 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.setFormat(CONST_FONT, 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);

		watermark = new FlxText(40, healthBar.y + 37, 0, "", 16);
		watermark.setFormat(CONST_FONT, 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		watermark.scrollFactor.set();
		watermark.borderSize = 1.25;
		watermark.visible = !ClientPrefs.data.hideHud;
		add(watermark);

		songLeft = new FlxText(1140, healthBar.y + 37, 0, "0:00 • 0:00", 16);
		songLeft.setFormat(CONST_FONT, 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songLeft.scrollFactor.set();
		songLeft.borderSize = 1.25;
		songLeft.visible = !ClientPrefs.data.hideHud;
		add(songLeft);

		versionTxtSmth = new FlxText(FlxG.width - 320, 10, 400, "Astro Engine: v" + EngineData.VERSION, 32);
		versionTxtSmth.setFormat(CONST_FONT, 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionTxtSmth.scrollFactor.set();
		versionTxtSmth.updateHitbox();
		versionTxtSmth.visible = !ClientPrefs.data.hideHud;
		add(versionTxtSmth);

		watermark.text = '{1} • {2}'.substitute([
			PlayState.SONG.song.replace("-", ' ').capitalize(),
			Difficulty.list[PlayState.storyDifficulty]
		]);

		addCurveBG(watermark.x - 10, scoreText.y + 4.5, watermark.fieldWidth + 20, 35, 35, 0, uiBackgroundGroup); // WaterMark
		addCurveBG(healthBar.x, scoreText.y + 4.5, 600, 35, 35, 0, uiBackgroundGroup); // ScoreBar
		addCurveBG(songLeft.x - 12.5, scoreText.y + 4.5, 125, 35, 35, 0, uiBackgroundGroup); // TimeBar (Alt)

		songLeft.y += 10;
		watermark.y += 10;
		scoreText.y += 10;

		super.create();

		timeTxt.setFormat(CONST_FONT, 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	}

	override function startSong():Void
	{
		uiBackgroundGroup.forEach(function(spr:FlxSprite) FlxTween.tween(spr, {alpha: 0.6}, 0.5, {ease: FlxEase.circOut}));
		super.startSong();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		songLeft.text = '{1} • {2}'.substitute([
			FlxStringUtil.formatTime(Math.max(0, Math.floor((Conductor.songPosition - ClientPrefs.data.noteOffset) / 1000)), false),
			FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false)
		]);
	}

	override function updateScore():Void
	{
		scoreText.text = 'Score: {1} • Misses: {2} • Rating: {3}{4}'.substitute([
			// i love this func
			game.songScore,
			game.songMisses,
			game.ratingName,
			(game.ratingName != '?' ? ' (${Highscore.floorDecimal(game.ratingPercent * 100, 2)}%) - ${game.ratingFC}' : '')
		]);
	}

	function addCurveBG(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0, ellipseScale:Int = 0, startAlpha:Int = 0, ?group:FlxGroup)
	{
		// width and height
		final width:Int = Std.int(width);
		final height:Int = Std.int(height);

		final curveSpr:FlxSprite = new FlxSprite(x, y).makeGraphic(width, height, FlxColor.TRANSPARENT, false);// make solid doesn't work with this :((
		curveSpr.drawRoundRect(0, 0, width, height, ellipseScale, ellipseScale, FlxColor.BLACK);
		curveSpr.alpha = startAlpha;

		if (group != null) group.add(curveSpr);
	}
}
