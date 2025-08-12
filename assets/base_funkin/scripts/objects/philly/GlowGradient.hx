package objects.philly;

class GlowGradient extends FlxSprite
{
	public var originalY:Float;
	public var originalHeight:Int = 400;
	public var intendedAlpha:Float = 1;

	public function new(x:Float, y:Float):Void
	{
		super(x, y);
		originalY = y;

		loadGraphic(Paths.image('philly/gradient'));
		antialiasing = ClientPrefs.data.antialiasing;
		scrollFactor.set(0, 0.75);
		setGraphicSize(2000, originalHeight);
		updateHitbox();
	}

	override function update(elapsed:Float):Void
	{
		var newHeight:Int = Math.round(height - 1000 * elapsed);
		if (newHeight > 0)
		{
			alpha = intendedAlpha;
			setGraphicSize(2000, newHeight);
			updateHitbox();
			y = originalY + (originalHeight - height);
		}
		else
		{
			alpha = 0;
			y = -5000;
		}

		super.update(elapsed);
	}

	public function bop():VOid
	{
		setGraphicSize(2000, originalHeight);
		updateHitbox();
		y = originalY;
		alpha = intendedAlpha;
	}
}
