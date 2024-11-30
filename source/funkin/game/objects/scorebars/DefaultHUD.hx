package funkin.game.objects.scorebars;

import flixel.util.FlxStringUtil;

class DefaultHUD extends FlxBasic
{
	private var game(get, never):PlayState;

	private var scoreText:FlxText;

	public var timeBar:Bar;
	public var timeTxt:FlxText;
	public var healthBar:Bar;

	// Health Icons
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	private var updateTime:Bool = true;

	function create()
	{
		game.baseUI = this;
		
		createHealthBar();
		createSongTimer();
	}

	function createHealthBar()
	{
		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return game.health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		game.uiGroup.add(healthBar);

		// furry
		iconP1 = new HealthIcon(game.boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideFullHUD;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		game.uiGroup.add(iconP1);

		iconP2 = new HealthIcon(game.dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideFullHUD;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		game.uiGroup.add(iconP2);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}

	public function beatHit() {
		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	public function reloadHealthBarColors()
	{
		final dadColor:FlxColor = FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]);
		final boyfriendColor:FlxColor = FlxColor.fromRGB(game.boyfriend.healthColorArray[0], game.boyfriend.healthColorArray[1],
			game.boyfriend.healthColorArray[2]);
		healthBar.setColors(dadColor, boyfriendColor);
	}

	function createSongTimer()
	{
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 14, 400, "", 32);
		timeTxt.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.screenCenter(X);
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;

		if (ClientPrefs.data.downScroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.data.timeBarType == 'Song Name')
			timeTxt.text = PlayState.SONG.song;

		updateTime = showTime;

		@:privateAccess
		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return game.songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		timeBar.leftBar.color = FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]);
		game.uiGroup.add(timeBar);

		game.uiGroup.add(timeTxt);

		if (ClientPrefs.data.hideFullHUD)
			timeBar.visible = false;
		else
			timeBar.visible = showTime;

		if (ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
	}

	@:noCompletion private inline function get_game():Dynamic
		return PlayState.instance;

	function startSong()
	{
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
	}

	function add(object:FlxSprite)
		game.uiGroup.add(object);
}
