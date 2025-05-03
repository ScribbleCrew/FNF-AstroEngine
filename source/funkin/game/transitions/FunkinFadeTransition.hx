package funkin.game.transitions;

class FunkinFadeTransition extends MusicBeatSubstate
{	
	/**
	* The finish callback duh...	
	*/
	public static var finishCallback:Void->Void;

	/**
	 * Is the transition going in or out.	
	 */
	@:noCompletion private var _isTransIn:Bool = false;

	/**
	 * The fade duration.	
	 */
	@:noCompletion private var _fadeDuration:Float;

	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	/**
	 * Constructor
	 * @param duration The fade duration.
	 * @param isTransIn Is it transiting in?	
	 */
	public function new(duration:Float, isTransIn:Bool):Void
	{
		this._fadeDuration = duration;
		this._isTransIn = isTransIn;

		super();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	/**
	 * StartTransition
	 * Custom made Trans in
	 * @param nextState The Next State.	
	 */
	public static function startTransition(nextState:FlxState = null):Void
	{
		if (nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new FunkinFadeTransition(0.6, false));
		nextState == FlxG.state ? FunkinFadeTransition.finishCallback = () -> FlxG.resetState() : FunkinFadeTransition.finishCallback = () ->
			FlxG.switchState(nextState);
	}

	@:dox(hide) override function create():Void
	{
		final width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		final height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));

		transGradient = FlxGradient.createGradientFlxSprite(1, height, (_isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		transGradient.y = _isTransIn ? (transBlack.y - transBlack.height) : -transGradient.height;

		super.create();
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);

		_fadeDuration > 0 ? (transGradient.y += (height + targetPos) * elapsed / _fadeDuration) : (transGradient.y = (targetPos) * elapsed);
		transBlack.y = _isTransIn ? (transGradient.y + transGradient.height) : (transGradient.y - transBlack.height);

		if (transGradient.y >= targetPos) close();
	}

	// Don't delete this
	@:dox(hide) override function close():Void
	{
		super.close();

		if (finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
