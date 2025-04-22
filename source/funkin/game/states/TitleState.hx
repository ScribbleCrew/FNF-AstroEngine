package funkin.game.states;

import haxe.xml.Access;
import flixel.addons.transition.FlxTransitionableState;

using funkin.backend.CoolUtil;

/**
 * Title data struc type.
 */
typedef TitleData =
{
	// title logo position.
	logoPosition:FlxPoint,

	// start text position.
	startTextPosition:FlxPoint,

	// title text colors.
	startTextColors:Array<TitleStartColor>,

	// girlfriend position.
	gfPosition:FlxPoint,

	// background sprite string.
	backgroundSprite:String,

	// beat per minute(?).
	bpm:Int
}

/**
 * The title start text color type.	
 */
typedef TitleStartColor =
{
	// color, duh
	color:FlxColor,

	// alpha, duh
	alpha:Float
}

@:access(flixel.animation.FlxAnimationController)
class TitleState extends MusicBeatState
{
	/**
	 * Title data.	
	 */
	var _data:TitleData;

	/**
	 * Has title state been initialized.
	 */
	public static var initialized:Bool = false;

	/**
	 * Custom title text stuff.	
	 */
	var curWacky:Array<String> = [];

	/**
	 * newsground sprite.	
	 */
	var newsgroundSprite:FlxSprite = new FlxSprite(); // fix stupid flixel shi.

	#if CHECK_FOR_UPDATES
	/**
	 * The update version (the newer version of this engine).
	 */
	public static var updateVersion:String = '';

	/**
	 * If the users game needs to be updated or not.
	 */
	var _mustUpdate:Bool = false;
	#end

	override public function create():Void
	{
		curWacky = FlxG.random.getObject(introTextList);

		// optim memory
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		// discord & window stuff
		#if desktop
		#if DISCORD_ALLOWED DiscordClient.changePresence("Browsing the menus", null); #end
		WindowUtil.title = '%{GAME_TITLE}';
		FlxG.mouse.visible = false;
		#end

		// Update checking.
		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates && !closedState)
		{
			Logs.prefixedTrace('Checking for update', 'Update Sync', CYAN);

			final http:haxe.Http = new haxe.Http("https://raw.githubusercontent.com/ScribbleCrew/FNF-AstroEngine/main/gitVersion.txt");
			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();

				final curVersion:String = EngineData.VERSION.trim();
				Logs.prefixedTrace('version online: $updateVersion your version: $curVersion', 'Update Sync', CYAN);
				if (updateVersion != curVersion)
				{
					Logs.prefixedTrace('Versions aren\'t matching!', 'Update Sync', RED);
					_mustUpdate = true;
				}
			}
			http.onError = (error) -> trace('error: $error');
			http.request();
		}
		#end

		// fallback :3c
		// `_data` needs to be init'd before using.
		_data = {
			logoPosition: FlxPoint.get(-150, -100),
			startTextPosition: FlxPoint.get(100, 576),
			gfPosition: FlxPoint.get(512, 40),
			bpm: 102,
			backgroundSprite: "",
			startTextColors: [
				{
					color: 0xFFFFA033,
					alpha: 1
				},
				{color: 0xFF3333CC, alpha: .64}
			]
		};

		// load data.
		#if TITLE_SCREEN_XML loadXMLData(); #end

		persistentUpdate = persistentDraw = !initialized;

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
			initialized ? startIntro() : new FlxTimer().start(1, (tmr:FlxTimer) -> startIntro());
		#end

		// Stats testing.
		final maxS = FlxG.save.data.stats.get('Max Score');
		final mostM = FlxG.save.data.stats.get('Max Misses');
		if (mostM != null && maxS != null)
			Logs.prefixedTrace('Max Score: $maxS - Max Misses: $mostM', 'Info', ORANGE);
	}

	/**
	 * Has the intro been skipped.	
	 */
	var skippedIntro:Bool = false;

	/**
	 * Skip intro function.	
	 */
	function skipIntro():Void
		if (!skippedIntro)
		{
			introGroup.empty();
			remove(introGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
		}

	#if TITLE_SCREEN_XML
	/**
	 * Load XML data.
	 */
	function loadXMLData():Void
	{
		try
		{
			final xml:Access = new Access(Xml.parse(Paths.getTextFromFile('data/config/titlescreen.xml')).firstElement());
			if (xml != null)
			{
				// Title logo position xml data.
				final logoPos = FlxPoint.get(-150, -100);
				final node:Access = xml.node.logo;
				if (node.name != null)
					logoPos.set(Std.parseFloat(node.has.x ? node.att.x : null).getDefault(-150),
						Std.parseFloat(node.has.y ? node.att.y : null).getDefault(-100));
				_data.logoPosition = logoPos;

				// Start text xml data.
				final startTextPos = FlxPoint.get(100, 576);
				final node:Access = xml.node.startText;
				if (node.name != null)
					startTextPos.set(Std.parseFloat(node.has.x ? node.att.x : null).getDefault(100),
						Std.parseFloat(node.has.y ? node.att.y : null).getDefault(576));
				_data.startTextPosition = startTextPos;

				// Title text color xml data.
				function extractTitleColor(colorNode:Access):TitleStartColor
					return {
						color: colorNode.has.color ? colorNode.att.color.colorFromString() : FlxColor.WHITE,
						alpha: Std.parseFloat(colorNode.has.alpha ? colorNode.att.alpha : null).getDefault(1.0)
					}

				final colorStartData = node.has.colorStart ? extractTitleColor(node.node.colorStart) : {color: 0xFF33FFFF, alpha: 1.0};
				final colorEndData = node.has.colorEnd ? extractTitleColor(node.node.colorEnd) : {color: 0xFF3333CC, alpha: .64};
				_data.startTextColors = [colorStartData, colorEndData];

				// Girlfriend xml data.
				final gfPos = FlxPoint.get(512, 40);
				final node:Access = xml.node.gf;
				if (node.name != null)
					gfPos.set(Std.parseFloat(node.has.x ? node.att.x : null).getDefault(512), Std.parseFloat(node.has.y ? node.att.y : null).getDefault(40));
				_data.gfPosition = gfPos;

				// BPM and background sprite xml data.
				_data.bpm = Std.parseInt(xml.has.bpm ? xml.att.bpm : null).getDefault(102);
				_data.backgroundSprite = xml.has.backgroundSprite ? xml.att.backgroundSprite : "";
			}
		}
		catch (error:Dynamic)
			Logs.prefixedTrace(error, 'Credits State', RED);
	}
	#end

	/**
	 * Title intro text group.	
	 */
	var introGroup:TitleIntroGroup;

	/**
	 * Friday Night Funkin' Logo.	
	 */
	var logo:FlxSprite;

	/**
	 * Girlfriend dance.	
	 */
	var gfDance:FlxSprite;

	/**
	 * Should Girlfriend dance left.	
	 */
	var danceLeft:Bool = false;

	/**
	 * Enter text.	
	 */
	var titleText:FlxSprite;

	/**
	 * Color swap shader.
	 */
	var swagShader:ColorSwap = null;

	/**
	 * Start the intro.	
	 */
	function startIntro():Void
	{
		if (!initialized)
			if (FlxG.sound.music == null)
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		Conductor.bpm = _data.bpm;
		persistentUpdate = true;

		// background
		final bg:FlxSprite = new FlxSprite();
		if (_data.backgroundSprite != null && _data.backgroundSprite.length > 0 && _data.backgroundSprite != "none")
			bg.loadGraphic(Paths.image(_data.backgroundSprite));
		else
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		// logo.
		logo = new FlxSprite(_data.logoPosition.x, _data.logoPosition.y);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play('bump');
		logo.updateHitbox();

		// color swap shader.
		swagShader = new ColorSwap();

		// girlfriend dancing anim.
		gfDance = new FlxSprite(_data.gfPosition.x, _data.gfPosition.y);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;
		gfDance.shader = swagShader.shader;
		add(gfDance);

		// logo shader.
		logo.shader = swagShader.shader;
		add(logo);

		final animFrames:Array<flixel.graphics.frames.FlxFrame> = [];
		titleText = new FlxSprite((_data.startTextPosition.x + 30), _data.startTextPosition.y);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		// anim handler
		newTitle = (animFrames.length > 0);
		titleText.animation.addByPrefix('idle', animFrames.length > 0 ? "ENTER IDLE" : "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', animFrames.length > 0 ? (ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE") : "ENTER PRESSED", 24);

		titleText.antialiasing = ClientPrefs.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		add(introGroup = new TitleIntroGroup());

		// newsground sprite stuff.
		newsgroundSprite = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		newsgroundSprite.visible = false;
		newsgroundSprite.setGraphicSize(Std.int(newsgroundSprite.width * 0.8));
		newsgroundSprite.updateHitbox();
		newsgroundSprite.screenCenter(X);
		newsgroundSprite.antialiasing = ClientPrefs.data.antialiasing;
		introGroup.add(newsgroundSprite);

		initialized ? skipIntro() : initialized = true;
	}

	/**
	 * Intro text list.	
	 */
	var introTextList(get, never):Array<Array<String>>;

	@:dox(hide) function get_introTextList():Array<Array<String>>
		return [
			for (i in #if MODS_ALLOWED Mods.mergeAllTextsNamed('data/introText.txt') #else Assets.getText(Paths.txt('introText'))
				.split('\n') #end) i.split('--')
		];

	/**
	 * Is the state transitioning.	
	 */
	var transitioning:Bool = false;

	/**
	 *	New title???
	 */
	var newTitle:Bool = false;

	/**
	 * The title timer.	
	 */
	var titleTimer:Float = 0;

	@:dox(hide) override function update(elapsed:Float):Void
	{
		final mult:Float = FlxMath.lerp(1, FlxG.camera.zoom, MathsAddon.boundTo(1 - (elapsed * 9 * 1), 0, 1));
		FlxG.camera.zoom = mult;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;


		#if mobile for (touch in FlxG.touches.list)
			if (touch.justPressed)
				pressedEnter = true; 
		#end
		
		// game controller support.
		final gamepad:flixel.input.gamepad.FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START) pressedEnter = true;
			#if switch if (gamepad.justPressed.B) pressedEnter = true; #end
		}

		if (newTitle)
		{
			titleTimer += MathsAddon.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1) timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(_data.startTextColors[0].color, _data.startTextColors[1].color, timer);
				titleText.alpha = FlxMath.lerp(_data.startTextColors[0].alpha, _data.startTextColors[1].alpha, timer);
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

				new FlxTimer().start(1, function(tmr:FlxTimer):Void
				{
					MusicBeatState.switchState(#if CHECK_FOR_UPDATES _mustUpdate ? new funkin.game.states.OutdatedState() : #end
						new funkin.game.states.MainMenuState());
					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		// hue control.
		if (swagShader != null)
		{
			if (controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	/**
	 * Has the state been closed.	
	 */
	public static var closedState:Bool = false;

	/**
	 * Basically curBeat but won't be skipped if you hold the tab or resize the screen	
	 */
	private var sickBeats:Int = 0;

	@:dox(hide) override function beatHit():Void
	{
		super.beatHit();

		// logo bump animation, maybe use flxtweens instead?
		if (logo != null) logo.animation.play('bump', true);

		// girlfriend dancin'
		if (gfDance != null)
		{
			danceLeft = !danceLeft;
			gfDance.animation.play(danceLeft ? 'danceRight' : 'danceLeft');
		}

		// intro beats.
		if (!closedState)
		{
			// basically controls the fnf intro
			sickBeats++;
			switch (sickBeats) // TODO: include this inside the .xml file.
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					introGroup.create(['Astro Engine by'], FlxPoint.get(0, 40));
				case 4:
					introGroup.include('YourFriendOrbl', FlxPoint.get(0, 40));
				case 5:
					introGroup.empty();
				case 6:
					introGroup.create(['Not associated', 'with'], FlxPoint.get(0, -40));
				case 8:
					introGroup.include('newgrounds', FlxPoint.get(0, -40));
					newsgroundSprite.visible = true;
				case 9:
					introGroup.empty();
					newsgroundSprite.visible = false;
				case 10:
					introGroup.create([curWacky[0]]);
				case 12:
					introGroup.include(curWacky[1]);
				case 13:
					introGroup.empty();
				case 14:
					introGroup.create(['Friday']);
				case 15:
					introGroup.include('Night');
				case 16:
					introGroup.include('Funkin');
				case 17:
					skipIntro();
			}
		}
	}
}
