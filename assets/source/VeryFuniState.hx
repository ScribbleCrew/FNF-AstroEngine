// Shouldn't be static as this is a returning state (going to be used more than once).
var leftState:Bool = false;
var background:FlxSprite;
var title:FlxText;
var daKisser:FlxSprite;

// window timer
var titleTimer:FlxTimer;

/**
 * Window title options.	
 */
final titles:Array<String> = [':3', '>:3c', '>;3c', '=3', ';3c', ';3', ':3c'];

function setupTitleChanger():Void
{
	titleTimer = new FlxTimer().start(2.5, (timer) -> WindowUtil.title = titles[FlxG.random.int(0, titles.length - 1)], 0);
	titleTimer.onComplete(titleTimer);
}

function onCreate():Void
{
	setupTitleChanger();

	add(background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE));

	title = new FlxText().setFormat(Paths.font("Futura-CondensedExtraBold.otf", 'embed'), 70, FlxColor.BLACK, FlxTextAlign.CENTER);
	title.text = "Oooooo you like boys\nur a boykisser".toLowerCase();
	title.y += 25;
	title.screenCenter(FlxAxes.X);
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

function onDestroy():Void
{
	titleTimer = FlxDestroyUtil.destroy(titleTimer);
}

function onUpdate(elapsed:Float):Void
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
