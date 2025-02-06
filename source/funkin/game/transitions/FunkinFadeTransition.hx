package funkin.game.transitions;

class FunkinFadeTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;

	@:noCompletion private var _isTransIn:Bool = false;
	@:noCompletion private var _fadeDuration:Float;

	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) : Void
	{
		this._fadeDuration = duration;
		this._isTransIn = isTransIn;

		super();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function create() : Void
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

		if (_isTransIn)
			transGradient.y = transBlack.y - transBlack.height;
		else
			transGradient.y = -transGradient.height;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
		if (_fadeDuration > 0)
			transGradient.y += (height + targetPos) * elapsed / _fadeDuration;
		else
			transGradient.y = (targetPos) * elapsed;

		if (_isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		if (transGradient.y >= targetPos)
			close();
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if (finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
