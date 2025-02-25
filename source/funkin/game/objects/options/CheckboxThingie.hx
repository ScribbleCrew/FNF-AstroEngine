package funkin.game.objects.options;

class CheckboxThingie extends FlxRGBSprite
{
	public var sprTracker:FlxSprite;

	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var daValue(default, set):Bool;
	@:dox(hide) inline function set_daValue(check:Bool):Bool
	{
		if (check)
		{
			if (animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking')
			{
				animation.play('checking', true);
				offset.set(34, 25);
			}
		}
		else if (animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking')
		{
			animation.play("unchecking", true);
			offset.set(25, 28);
		}

		return check;
	}

	private var colorArray:Array<String> = Mods.mergeAllTextsNamed('data/checkboxColors.txt');

	public function new(x:Float = 0, y:Float = 0, ?checked = false):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkbox');

		animation.addByPrefix("unchecked", "static", 1, false);
		animation.addByPrefix("unchecking", "deselected", 24, false);
		animation.addByPrefix("checking", "selected", 24, false);
		animation.addByPrefix("checked", "finished", 1, false);

		antialiasing = funkin.backend.utils.ClientPrefs.data.antialiasing;
		setGraphicSize(Std.int(0.9 * width));
		updateHitbox();

		if (colorArray != null)
		{
			r = FlxColor.fromString(colorArray[0]) ?? 0xFFCC00;
			g = FlxColor.fromString(colorArray[1]) ?? 0xFFFFFFFF;
			b = FlxColor.fromString(colorArray[2]) ?? 0xE97813;
		}

		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		daValue = checked;
	}

	private function animationFinished(name:String):Void
	{
		switch (name)
		{
			case 'checking':
				animation.play('checked', true);
				offset.set(3, 12);

			case 'unchecking':
				animation.play('unchecked', true);
				offset.set(0, 2);
		}
	}

	override function update(elapsed:Float):Void
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y + 30 + offsetY);

			if (copyAlpha)
				alpha = sprTracker.alpha;
		}

		super.update(elapsed);
	}
}
