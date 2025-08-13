package flixel.text;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

class AttachedFlxText extends flixel.text.FlxText
{
	@:dox(hide) @:noCompletion var __trackerSpr(default, null):FlxSprite;

	/**
	* The spr tracker.
	*/
	@:isVar public var sprTracker(get, set):FlxSprite;
	@:dox(hide) inline function set_sprTracker(_:FlxSprite):FlxSprite return __trackerSpr = _;
	@:dox(hide) inline function get_sprTracker():FlxSprite return __trackerSpr;

	/**
	* The tracked sprites offset.
	*/
	public var trackerOffset:FlxPoint;

	/**
	* Things that should be copied.	
	*/
	public var copy:OptionsType;

	/**
	 * [Description] The X offset of the tracker.
	 * @deprecated use `trackerOffset.x` instead!!!
	 * @returns Float Returns the X offset of the tracker.
	 */
	@:isVar 
	@:deprecated("DEPRECATED, use `trackerOffset.x` instead!!!")
	public var offsetX(default,set):Float = 0;
	@:dox(hide) inline function set_offsetX(value:Float):Float
		return offsetX = trackerOffset.x = value;

	/**
	 * [Description] The Y offset of the tracker.
	 * @deprecated use `trackerOffset.y` instead!!!
	 * @returns Float Returns the Y offset of the tracker.
	 */
	@:isVar 
	@:deprecated("DEPRECATED, use `trackerOffset.y` instead!!!")
	public var offsetY(default,set):Float = 0;
	@:dox(hide) inline function set_offsetY(value:Float):Float
		return offsetY = trackerOffset.y = value;

	public override function new(text:String = "", ?offset:FlxPoint):Void
	{
		offset??=FlxPoint.get(0, 0);

		super(0, 0, text ?? "", bold ?? false);
		this.offsetX = this.trackerOffset.x = (offset.x ?? 0);
		this.offsetY = this.trackerOffset.y = (offset.y ?? 0);
	}

	@:dox(hide) function __refresh():Void {
		setPosition(__trackerSpr.x + (trackerOffset.x ?? 0), __trackerSpr.y + (trackerOffset.y ?? 0));
		if (copy.visible) visible = __trackerSpr.visible;
		if (copy.alpha) alpha = __trackerSpr.alpha;
	}

	@:dox(hide) override function destroy() : Void {
		trackerOffset = FlxDestroyUtil.put(trackerOffset);
		super.destroy();
	}

	@:dox(hide) override function initVars():Void {
		super.initVars();

		trackerOffset = new FlxPoint();
		copy.visible = true;
		copy.alpha = false;
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		if (__trackerSpr != null)
			__refresh();

		super.update(elapsed);
	}
}

@:dox(hide) typedef OptionsType = {
	var visible:Bool;
	var alpha:Bool;
}