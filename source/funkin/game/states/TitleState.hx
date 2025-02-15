package funkin.game.states;

import flixel.input.gamepad.FlxGamepad;
import flixel.graphics.frames.FlxFrame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;

private typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

@:access(flixel.animation.FlxAnimationController)
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	final titleTextColors:Array<{color:FlxColor, alpha:Float}> = [{color: 0xFF33FFFF, alpha: 1}, {color: 0xFF3333CC, alpha: .64}];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		#if desktop
		#if DISCORD_ALLOWED DiscordClient.changePresence("Browsing the menus", null); #end
		WindowUtil.title = '%{GAME_TITLE}';
		FlxG.mouse.visible = false;
		#end

		curWacky = FlxG.random.getObject(getIntroText());

		// DEBUG BULLSHIT
		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates && !closedState)
		{
			Logs.prefixedTrace('Checking for update', 'Update Sync', CYAN);

			final http:haxe.Http = new haxe.Http("https://raw.githubusercontent.com/ScribbleCrew/FNF-AstroEngine/main/gitVersion.txt");
			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();

				final curVersion:String = EngineData.VERSION.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				Logs.prefixedTrace('version online: $updateVersion your version: $curVersion', 'Update Sync', CYAN);
				if (updateVersion != curVersion)
				{
					Logs.prefixedTrace('Versions aren\'t matching!', 'Update Sync', RED);
					mustUpdate = true;
				}
			}
			http.onError = (error) -> trace('error: $error');
			http.request();
		}
		#end

		titleJSON = tjson.TJSON.parse(Paths.getTextFromFile('data/json/titleJson.json'));

		if (!initialized)
			persistentUpdate = persistentDraw = true;

		#if FREEPLAY
		MusicBeatState.switchState(new game.states.FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			if (initialized)
				startIntro();
			else
				new FlxTimer().start(1, (tmr:FlxTimer) -> startIntro());
		}
		#end

		final maxS = FlxG.save.data.stats.get('Max Score');
		final mostM = FlxG.save.data.stats.get('Max Misses');
		if (mostM != null && maxS != null)
			Logs.print('Max Score: $maxS - Max Misses: $mostM');
	}

	var introGroup:TitleIntroGroup;
	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro():Void
	{
		if (!initialized)
			if (FlxG.sound.music == null)
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none")
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		else
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		swagShader = new ColorSwap();

		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;
		gfDance.shader = swagShader.shader;
		add(gfDance);

		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite((titleJSON.startx + 30), titleJSON.starty);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0)
		{
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}

		titleText.antialiasing = ClientPrefs.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		introGroup = new TitleIntroGroup();
		add(introGroup);

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroText():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end

		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if ASTRO_WATERMARKS
		if (FlxG.keys.justPressed.SEVEN)
			MusicBeatState.switchState(new funkin.game.states.owo.VeryFuniState(new TitleState()));
		#end

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		final gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (newTitle)
		{
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0].color, titleTextColors[1].color, timer);
				titleText.alpha = FlxMath.lerp(titleTextColors[0].alpha, titleTextColors[1].alpha, timer);
			}

			if (pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;

				if (titleText != null)
					titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate)
						MusicBeatState.switchState(new funkin.game.states.OutdatedState());
					else
						MusicBeatState.switchState(new funkin.game.states.MainMenuState());

					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		if (swagShader != null)
		{
			if (controls.UI_LEFT)
				swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT)
				swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null)
			logoBl.animation.play('bump', true);

		if (gfDance != null)
		{
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if (!closedState)
		{
			// basically controls the fnf intro
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					introGroup.create(['Psych Engine by'], 40);
				case 4:
					introGroup.make('Shadow Mario', 40);
					introGroup.make('Riveren', 40);
				case 5:
					introGroup.delete();
				case 6:
					introGroup.create(['Not associated', 'with'], -40);
				case 8:
					introGroup.make('newgrounds', -40);
					introGroup.newsgroundSprite.visible = true;
				case 9:
					introGroup.delete();
					introGroup.newsgroundSprite.visible = false;
				case 10:
					introGroup.create([curWacky[0]]);
				case 12:
					introGroup.make(curWacky[1]);
				case 13:
					introGroup.delete();
				case 14:
					introGroup.make('Friday');
				case 15:
					introGroup.make('Night');
				case 16:
					introGroup.make('Funkin');
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(introGroup.newsgroundSprite);
			remove(introGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);

			skippedIntro = true;
		}
	}
}
