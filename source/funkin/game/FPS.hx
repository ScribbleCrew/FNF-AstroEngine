package funkin.game;

import openfl.display.Sprite;

/**
 * The FPS class provides an easy-to-use monitor to display
 * the current frame rate of an OpenFL project.
 *
 * NOTICE:
 * Slightly modified for Astro Engine.
 */
@:access(openfl.display.DisplayObject)
class FPS extends openfl.text.TextField
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 *	The current frame rate (expressed using frames-per-second)
	 */
	public var currentFPS(default, null):Int;

	/**
	 * Amount of times fps updated?
	 */
	private var times:Array<Float>;

	/**
	 *	The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	 */
	@:isVar
	public var memoryMegas(get, never):Float;
	@:noCompletion private inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

	/**
	 * The background sprite.
	 */
	public var bgSprite:Sprite;

	/**
	 * The background offset.
	 */
	public var bgOffset:FlxPoint = FlxPoint.get();

	/**
	 * Pushes a string to the text variable (FPS Stuff)
	 */
	public inline function addLine(str:String = ""):String
		return text += '${text != '' ? '\n' : ''}$str';

	/**
	 * Reset's everything lol...
	 */
	public inline function clear():String
		return text = '';

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 14, color, false);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		bgSprite = new Sprite();
		bgSprite.graphics.beginFill(0xFF000000);
		bgSprite.graphics.drawRect(0, 0, 1, 1);
		bgSprite.graphics.endFill();
		bgSprite.alpha = bgAlpha;
		visible = active = bgSprite.visible = ClientPrefs.data.showFPS;

		times = [];

		updateFPS = defaultFramerateUpdate;
	}

	/**
	 * prevents the overlay from updating every frame, why would you need to anyways. - @crowplexus
	 */
	var deltaTimeout:Float = 0.0;
	public var updateFPS:Void->Void;
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (deltaTimeout < 50)
		{
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateFPS();
		deltaTimeout = 0.0;

		bgSprite.scaleX = this.width + bgOffset.x * 2 - 10;
		bgSprite.scaleY = this.height + bgOffset.y * 2 + 3;
		bgSprite.x = this.x - bgOffset.x;
		bgSprite.y = this.y - bgOffset.y;
	}

	/**
	 * Framerate update function.
	 * can be used in hscript.
	 */
	public dynamic function defaultFramerateUpdate():Void
	{
		clear();
		addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "owo's per second" : #end 'FPS'}: $currentFPS');
		addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "proot mem usage" : #end 'Memory'}: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}');
		#if GIT_ALLOWED addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "orbl pick one pls 🙏" : #end "Commit"}: ${GitMacro.commitNumber} [${GitMacro.commitHash}] ${GitMacro.branch}'); #end
		
		(currentFPS < FlxG.drawFramerate * 0.5) ? textColor = 0xFFFF0000 : textColor = 0xFFFFFFFF;
	}

	/**
	 * Framerate background alpha float.
	 */
	private static inline final bgAlpha:Float = (1 / 3);
	@:noCompletion override function set_alpha(val:Float):Float
	{
		if (val < bgAlpha)
			bgSprite.alpha = val;
		return super.alpha = val;
	}

	@:noCompletion override function set_visible(val:Bool):Bool
		return bgSprite.visible = super.visible = val;
}
