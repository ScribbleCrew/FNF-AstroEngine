package funkin.backend.base;

import haxe.ds.StringMap;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

// messy code like always
@:access(funkin.game.states.PlayState.updateTime)
@:access(funkin.game.states.PlayState.songPercent)
@:access(funkin.game.states.PlayState.songLength)
abstract class UserInterface extends FlxBasic implements IFlxDestroyable
{
	// local member tracking :p
	var _members:Array<FlxBasic> = [];

	/**
	 * Current PlayState instance.	
	 */
	var game(get, never):PlayState;
	@:dox(hide) @:noCompletion inline function get_game():PlayState
		return PlayState.instance;

	// Bars
	public var timeBar:Bar;
	public var timeTxt:FlxText;
	public var healthBar:Bar;

	// Health Icons
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	// Botplay Txt
	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;
	public var scoreText:FlxText;

	public function create():Void
	{
	}

	public function createPost():Void
	{
	}

	public function updateScore():Void
	{
	}

	public function new(?blank:Bool = false):Void
	{
		game.ui = this;

		if (!blank) // blank ui, doesn't add healthbar, song timer or botplay txt
		{
			this.createHealthBar();
			this.createSongTimer();
			this.makeBotplayTxt();
		}

		if (this.game == null)
		{
			game.ui = null; // unless we unbind in playstate instead of in here...
			destroy();
		}
		else
		{
			super();
			create();
			game.uiGroup.forEach(_ -> _.alpha = 0); // failsafe
			FlxG.log.add('Scorebar Created');
			createPost();
		}
	}

	function makeBotplayTxt()
	{
		botplayTxt = new FlxText(400, ClientPrefs.data.downScroll ? healthBar.y + 70 : healthBar.y - 90, FlxG.width - 800, 'BOTPLAY', 32);
		botplayTxt.setFormat(Constants.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = game.cpuControlled;
		add(botplayTxt);
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
		add(healthBar);

		// furry
		iconP1 = new HealthIcon(game.boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(game.dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		add(iconP2);
	}

	inline public function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [game.camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * PlayState.daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		game.insert(game.members.indexOf(game.noteGroup), spr);
		FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				game.remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function beatHit():Void
	{
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
		final showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');

		timeTxt = new FlxText(PlayState.STRUM_X + (FlxG.width / 2) - 248, 14, 400, "0:00", 32);
		timeTxt.setFormat(Constants.DEFAULT_FONT, 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;

		if (ClientPrefs.data.downScroll)
			timeTxt.y = FlxG.height - 44;
		if (ClientPrefs.data.timeBarType == 'Song Name')
			timeTxt.text = PlayState.SONG.song;

		@:privateAccess {
			PlayState.instance.updateTime = showTime;

			timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return game.songPercent, 0, 1);
		}
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		timeBar.leftBar.color = FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]);
		add(timeBar);

		add(timeTxt);

		timeBar.visible = ClientPrefs.data.hideHud ? false : showTime;

		if (ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
	}

	public function startSong():Void
	{
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
	}

	public function getHealthIconMult(iconInstance:HealthIcon, elapsed:Float):Float
		return FlxMath.lerp(1, iconInstance.scale.x, MathsAddon.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));

	public function updateIcons(elapsed:Float):Void
	{
		final iconOffset:Int = 26;

		// icon player 1
		final iconP1Mult:Float = getHealthIconMult(iconP1, elapsed);
		iconP1.scale.set(iconP1Mult, iconP1Mult);
		iconP1.updateHitbox();

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;

		iconP1.animation.curAnim.curFrame = healthBar.percent < 20 ? 1 : 0;

		// icon player 2
		final iconP2Mult:Float = getHealthIconMult(iconP2, elapsed);
		iconP2.scale.set(iconP2Mult, iconP2Mult);
		iconP2.updateHitbox();

		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		iconP2.animation.curAnim.curFrame = healthBar.percent > 80 ? 1 : 0;
	}

	// !!! OVERRIDE FUNCTIONS !!!

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!game.startingSong)
		{
			if (!game.paused)
			{
				if (game.updateTime)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.data.noteOffset;
					if (curTime < 0)
						curTime = 0;
					game.songPercent = (curTime / game.songLength);

					var songCalc:Float = (game.songLength - curTime);
					if (ClientPrefs.data.timeBarType == 'Time Elapsed')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (ClientPrefs.data.timeBarType != 'Song Name')
						timeTxt.text = flixel.util.FlxStringUtil.formatTime(secondsTotal, false);
				}
			}
		}

		this.updateIcons(elapsed);

		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
	}

	@:dox(hide) override public function destroy():Void
	{
		for (num => spr in this._members)
			spr.destroy();
		super.destroy();
	}

	// !!! MODFIED ADD, REMOVE AND INSERT FUNCTIONS !!!

	/**
	 * User Interface `add` function.
	 * @param object 
	 * @param customGroup 
	 */
	public function add(object:FlxBasic, ?customGroup:flixel.group.FlxSpriteGroup):FlxBasic
	{
		final _obj = cast object;
		customGroup != null ? customGroup.add(_obj) : game.uiGroup.add(_obj);
		if (this._members != null && this._members.indexOf(object) == -1) this._members.push(_obj);
		return object;
	}

	/**
	 * User Interface `remove` function.
	 * @param object 
	 * @param customGroup 
	 */
	public function remove(object:FlxBasic, ?customGroup:flixel.group.FlxSpriteGroup):Void
	{
		final _obj = cast object;
		customGroup != null ? customGroup.remove(_obj) : game.uiGroup.remove(_obj);
		if (this._members != null && this._members.indexOf(object) == -1)
			this._members.remove(object);
	}

	/**
	 * User Interface `insert` function 
	 * @param position 
	 * @param object 
	 * @param customGroup 
	 */
	public function insert(position:Int, object:FlxBasic, ?customGroup:flixel.group.FlxSpriteGroup):FlxBasic
	{
		final _obj = cast object;
		customGroup != null ? customGroup.insert(position, _obj) : game.uiGroup.insert(position, _obj);
		if (this._members != null && this._members.indexOf(object) == -1)
			this._members.push(_obj);
		return object;
	}
}
