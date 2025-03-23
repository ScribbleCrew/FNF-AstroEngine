// Shouldn't be static as this is a returning state (going to be used more than once).
var leftState:Bool = false;

// sprites
var background:FlxSprite;
var title:FlxText;
var daKisser:FlxSprite;

// window timer
var titleTimer:FlxTimer;

// title options
final titles:Array<String> = [':3', '>:3c', '>;3c', '=3', ';3c', ';3', ':3c'];

// setup the window title changer
function setupTitleChanger():Void
{
	titleTimer = new FlxTimer().start(2.5, (timer) -> WindowUtil.title = titles[FlxG.random.int(0, titles.length - 1)], 0);
	titleTimer.onComplete(titleTimer);
}

function create():Void
{
	Logs.trace('gwa gwa gwa');

	setupTitleChanger();

	add(background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE));

	title = new FlxText("Oooooo you like boys\nur a boykisser".toLowerCase()).setFormat(Paths.font("Futura-CondensedExtraBold.otf", 'embed'), 70, 0xFFFFC0CB, FlxTextAlign.CENTER);
	title.screenCenter(FlxAxes.X);
	title.y += 25;
	title.updateHitbox();
	add(title);

	daKisser = new FlxSprite().loadGraphic(Paths.image('extra/kisser', 'embed'));
	daKisser.screenCenter();
	daKisser.updateHitbox();
	daKisser.y += 25;
	add(daKisser);

	FlxTween.tween(daKisser, {x: daKisser.x}, 0.3, {ease: FlxEase.expoOut, type: FlxTween.PINGPONG, onComplete: (twn) -> daKisser.flipX = !daKisser.flipX});
	FlxTween.num(Main.framerateCounter.alpha, 0, .6, {ease: FlxEase.expoOut, startDelay: .2}, Main.framerateCounter.set_alpha);
}

function destroy():Void
{
	titleTimer = FlxDestroyUtil.destroy(titleTimer);
}

function update(elapsed:Float):Void
{
	if (!leftState && FlxG.keys.justPressed.ANY)
	{
		leftState = true;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxTween.cancelTweensOf(daKisser);
		FlxG.camera.flash(0xFFFFC0CB);
		FlxTween.tween(FlxG.camera, {zoom: 1.8}, 6, {ease: FlxEase.expoOut});

		new FlxTimer().start(5.55, _ -> FlxG.camera.fade(FlxColor.BLACK, .1, false, () -> MusicBeatState.switchState(_return ?? new MainMenuState())));
		
		FlxTween.tween(title, {alpha: 0}, .5, {ease: FlxEase.expoOut});
		FlxTween.tween(background, {alpha: 0}, .75, {
			ease: FlxEase.expoOut,
			onComplete: _ -> FlxTween.tween(daKisser, {alpha: 0}, 3.5, {
				ease: FlxEase.expoOut,
				onComplete: _ ->
				{
					FlxTween.num(Main.framerateCounter.alpha, ClientPrefs.data.fpsCounterAlpha, .5, {ease: FlxEase.expoOut}, Main.framerateCounter.set_alpha);
					titleTimer.cancel();
					WindowUtil.title = '%{GAME_TITLE}'; // YEAH!
				}
			})
		});
	}
}
