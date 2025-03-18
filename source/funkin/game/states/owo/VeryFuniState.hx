package funkin.game.states.owo;

#if ASTRO_WATERMARKS
@:access(funkin.game.FPS)
class VeryFuniState extends MusicBeatState
{
	/**
	 * The returning state (the state you'll return to when leaving).	
	 */
	@:noCompletion var _return(default, null):FlxState = null;

	/**
	 *	Shouldn't be static as this is a returning state (going to be used more than once).
	 */
	@:dox(hide) var leftState:Bool = false;

	var background:FlxSprite;
	var title:FlxText;
	var daKisser:FlxSprite;

	/**
	 * Window title timer.
	 */
	var titleTimer:FlxTimer;

	/**
	 * Window title options.	
	 */
	final titleOptions:Array<String> = [":3", ">:3c",'>;3c', "=3", ";3c", ";3", ':3c'];

	@:dox(hide) override function create():Void
	{
		titleTimer = new FlxTimer().start(2.5, (timer) -> WindowUtil.title = titleOptions[FlxG.random.int(0, titleOptions.length - 1)], 0);
		titleTimer.onComplete(titleTimer);

		super.create();

		add(background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE));

		title = new FlxText().setFormat(Paths.font("Futura-CondensedExtraBold.otf", 'embed'), 70, FlxColor.BLACK, CENTER);
		title.text = "Oooooo you like boys\nur a boykisser".toLowerCase();
		title.y += 25;
		title.screenCenter(X);
		title.updateHitbox();
		add(title);

		daKisser = new FlxSprite().loadGraphic(Paths.image('extra/kisser', 'embed'));
		daKisser.screenCenter();
		daKisser.updateHitbox();
		daKisser.y += 25;
		add(daKisser);

		/**
		 * Tweens.	
		 */
		FlxTween.tween(daKisser, {x: daKisser.x}, 0.3, {ease: FlxEase.expoOut, type: FlxTween.PINGPONG, onComplete: (twn) -> daKisser.flipX = !daKisser.flipX});
		FlxTween.num(Main.framerateCounter.alpha, 0, .6, {ease: FlxEase.expoOut, startDelay: .2}, Main.framerateCounter.set_alpha);
	}

	@:dox(hide) override function destroy():Void
	{
		titleTimer = FlxDestroyUtil.destroy(titleTimer);

		super.destroy();
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!leftState && FlxG.keys.justPressed.ANY)
		{
			leftState = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.cancelTweensOf(daKisser);
			FlxG.camera.flash(FlxColorPastel.PASTELPINK);
			FlxTween.tween(FlxG.camera, {zoom: 1.8}, 6, {ease: FlxEase.expoOut});
			new FlxTimer().start(5.55, _ -> FlxG.camera.fade(FlxColor.BLACK, .1, false, () -> MusicBeatState.switchState(_return ?? new MainMenuState())));
			FlxTween.tween(title, {alpha: 0}, .5, {ease: FlxEase.expoOut});
			FlxTween.tween(background, {alpha: 0}, .75, {
				ease: FlxEase.expoOut,
				onComplete: _ -> FlxTween.tween(daKisser, {alpha: 0}, 3.5, {
					ease: FlxEase.expoOut,
					onComplete: _ ->
					{
						FlxTween.num(Main.framerateCounter.alpha, ClientPrefs.data.fpsCounterAlpha, .5, {ease: FlxEase.expoOut},
							Main.framerateCounter.set_alpha);
						titleTimer.cancel();
						WindowUtil.title = '%{GAME_TITLE}'; // YEAH!
					}
				})
			});
		}
	}

	@:dox(hide) public function new(?_return:FlxState):Void
	{
		super();
		this._return = _return;
	}
}
#end
