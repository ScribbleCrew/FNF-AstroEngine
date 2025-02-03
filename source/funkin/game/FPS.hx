package funkin.game;

#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if openfl
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.DisplayObject)
class FPS extends TextField
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	public var currentFPS(default, null):Int;
	public var bgSprite:Sprite;
	public var offset:FlxPoint = FlxPoint.get();

	private var cacheCount:Int;
	private var currentTime:Float;
	private var times:Array<Float>;
	var bgAlpha:Float = 1 / 3;

	inline function addLine(str:String = "", ?lineDown:Bool = true):String
		return text += '${lineDown ? '\n' : ''}$str';

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color, false);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		bgSprite = new Sprite();
		bgSprite.graphics.beginFill(0xFF000000);
		bgSprite.graphics.drawRect(0, 0, 1, 1);
		bgSprite.graphics.endFill();
		bgSprite.alpha = bgAlpha;
		visible = active = bgSprite.visible = ClientPrefs.data.showFPS;

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	@:noCompletion private override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
			times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.data.framerate)
			currentFPS = ClientPrefs.data.framerate;

		if (currentCount != cacheCount)
		{
			text = "";
			addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "owo's per second" : #end 'FPS'}: $currentFPS', false);

			#if openfl
			var memoryMegas:Float = 0;
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "proot mem usage" : #end 'Memory'}: ${memoryMegas} MB');
			#end

			#if GIT_ALLOWED
			addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "orbl pick one pls 🙏" : #end "Commit"}: ${GitMacro.commitNumber} [${GitMacro.commitHash}] ${GitMacro.branch}');
			#end

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			addLine();
			addLine('ntotalDC: ${Context3DStats.totalDrawCalls()}');
			addLine('nstageDC: ${Context3DStats.contextDrawCalls(DrawCallContext.STAGE)}');
			addLine('stage3DDC: ${Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D)}');
			#end

			textColor = 0xFFFFFFFF;
			if (#if openfl memoryMegas > 3000 || #end currentFPS <= ClientPrefs.data.framerate / 2)
				textColor = 0xFFFF0000;

			bgSprite.scaleX = this.width + offset.x * 2 - 10;
			bgSprite.scaleY = this.height + offset.y * 2 + 3;
		}

		cacheCount = currentCount;

		bgSprite.x = this.x - offset.x;
		bgSprite.y = this.y - offset.y;
	}

	@:noCompletion override function set_alpha(val:Float):Float{
		if(val < bgAlpha)
			bgSprite.alpha = val;
		return super.alpha = val;
	}

	@:noCompletion override function set_visible(val:Bool):Bool
		return bgSprite.visible = super.visible = val;
}
