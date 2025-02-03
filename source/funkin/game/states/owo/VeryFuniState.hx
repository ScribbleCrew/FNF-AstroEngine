package funkin.game.states.owo;

#if ASTRO_WATERMARKS
@:access(funkin.game.FPS)
class VeryFuniState extends MusicBeatState
{
	// The returning state, i guess.
	@:noCompletion var _return(default, null):FlxState = null;

	// Shouldn't be static as this is a returning state (going to be used more than once).
	var leftState:Bool = false;

	var background:FlxSprite;
	var title:FlxText;
	var daKisser:FlxSprite;

	public function new(?_return:FlxState):Void
	{
		super();
		this._return = _return;
	}

	override function create():Void
	{
		super.create();

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(background);

		title = new FlxText();
		title.setFormat(Paths.font("Futura-CondensedExtraBold.otf"), 70, FlxColor.BLACK, CENTER);
		title.text = "Oooooo you like boys\nur a boykisser".toLowerCase();
		//title.borderSize = 2;
		title.y += 25;
		title.screenCenter(X);
		title.updateHitbox();
		add(title);

		daKisser = new FlxSprite().loadGraphic(Paths.image('extra/kisser', 'embed'));
		daKisser.screenCenter();
		daKisser.updateHitbox();
		daKisser.y+=25;
		add(daKisser);
		FlxTween.tween(daKisser, {x: daKisser.x}, 0.3, {
			ease: FlxEase.expoOut,
			type: FlxTween.PINGPONG,
			onComplete: (twn) -> daKisser.flipX = !daKisser.flipX
		});
		FlxTween.num(Main.fpsVar.alpha, 0, .6, {ease: FlxEase.expoOut, startDelay: .2}, Main.fpsVar.set_alpha);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!leftState && FlxG.keys.justPressed.ANY)
		{
			leftState = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.cancelTweensOf(daKisser);
			FlxG.camera.flash(FlxColorPastel.PASTELPINK);
			FlxTween.num(Main.fpsVar.alpha, ClientPrefs.data.fpsCounterAlpha, .5, {ease: FlxEase.expoOut}, Main.fpsVar.set_alpha);

			new FlxTimer().start(4.25, _ ->
			{
				FlxG.camera.fade(FlxColor.BLACK, .1, false, () ->
				{
					trace('left state');
					MusicBeatState.switchState(_return ?? new MainMenuState());
				});
			});

			FlxTween.tween(title, {alpha: 0}, .5, {ease: FlxEase.expoOut});
			FlxTween.tween(background, {alpha: 0}, .75, {
				ease: FlxEase.expoOut,
				onComplete: _ ->
				{
					FlxTween.tween(daKisser, {
						alpha: 0 // ,
						// y: daKisser.y + 50
					}, 3.5, {
						ease: FlxEase.expoOut
					});
				}
			});
		}
	}
}
#end
