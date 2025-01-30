package flixel.text;

class AttachedAlphabet extends flixel.text.FlxText
{
	private var _tracker(default, null):FlxSprite;

	@:isVar
	public var sprTracker(get, set):FlxSprite;
	@:noCompletion private function set_sprTracker(spr:FlxSprite):FlxSprite
		return _tracker = sprTracker = spr;
	@:noCompletion  private function get_sprTracker():FlxSprite
		return _tracker;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;

	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0, ?bold = false, ?scale:Float = 1)
	{
		super(0, 0, text, bold);

		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float)
	{
		if (_tracker != null)
		{
			setPosition(_tracker.x + offsetX, _tracker.y + offsetY);
			if (copyVisible)
				visible = _tracker.visible;
			if (copyAlpha)
				alpha = _tracker.alpha;
		}

		super.update(elapsed);
	}
}
