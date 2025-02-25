package flixel.text;

import flixel.math.FlxPoint;

private typedef OptionsType = {
	var visible:Bool;
	var alpha:Bool;
}

class AttachedFlxText extends flixel.text.FlxText
{
	@:dox(hide) @:noCompletion var _tracker(default, null):FlxSprite;

	/**
	* The spr tracker.
	*/
	@:isVar public var sprTracker(get, set):FlxSprite;
	@:dox(hide) inline function set_sprTracker(spr:FlxSprite):FlxSprite return _tracker = spr;
	@:dox(hide) inline function get_sprTracker():FlxSprite return _tracker;

	/**
	* The tracked sprites offset.
	*/
	public var trackerOffset:FlxPoint;

	/**
	* Things that should be copied.	
	*/
	public var copy:OptionsType;

	// legacy support lmao (deprecated)
	@:isVar 
	@:deprecated("deprecated, use `trackerOffset` instead")
	public var offsetX(default,set):Float = 0;
	@:dox(hide) inline function set_offsetX(value:Float):Float
		return offsetX = trackerOffset.x = value;

	@:isVar 
	@:deprecated("deprecated, use `trackerOffset` instead")
	public var offsetY(default,set):Float = 0;
	@:dox(hide) inline function set_offsetY(value:Float):Float
		return offsetY = trackerOffset.y = value;

	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0, ?bold = false, ?scale:Float = 1):Void
	{
		super(0, 0, text, bold);

		this.offsetX = this.trackerOffset.x = offsetX;
		this.offsetY = this.trackerOffset.y = offsetY;
	}

	function refreshThis():Void {
		setPosition(_tracker.x + (trackerOffset.x ?? 0), _tracker.y + (trackerOffset.y ?? 0));
		if (copy.visible) visible = _tracker.visible;
		if (copy.alpha) alpha = _tracker.alpha;
	}

	@:noCompletion
	@:dox(hide) 
	override function initVars():Void {
		super.initVars();
		trackerOffset = new FlxPoint();
		copy.visible = true;
		copy.alpha = false;
	}

	@:dox(hide)
	override function update(elapsed:Float):Void
	{
		if (_tracker != null)
			refreshThis();

		super.update(elapsed);
	}
}
