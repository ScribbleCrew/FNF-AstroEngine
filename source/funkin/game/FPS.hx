package funkin.game;

import openfl.display.Sprite;
import haxegithub.utils.*;
import funkin.backend.data.EngineData;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
import funkin.backend.utils.ClientPrefs;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end
#if openfl
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
class FPS extends TextField
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	public var currentFPS(default, null):Int;
	public var bgSprite:Sprite;
	public var offsetX:Float;
	public var offsetY:Float;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

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
		bgSprite.alpha = 1 / 3;
		visible = active = bgSprite.visible = ClientPrefs.data.showFPS;

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.data.framerate)
			currentFPS = ClientPrefs.data.framerate;

		if (currentCount != cacheCount)
		{
			text = '${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "owo's per second" : #end 'FPS'}: $currentFPS';

			var memoryMegas:Float = 0;

			#if openfl
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			text += '\n${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "proot mem usage" : #end 'Memory'}: ${memoryMegas} MB';
			#end

			#if debug
			text += '\n${#if ASTRO_WATERMARKS ClientPrefs.data.gayFurryStuff ? "orbl pick one pls 🙏" : #end "Commit"}: ${GitMacro.commitNumber} [${GitMacro.commitHash}] ${GitMacro.branch}';
			#end

			textColor = 0xFFFFFFFF;
			if (memoryMegas > 3000 || currentFPS <= ClientPrefs.data.framerate / 2)
				textColor = 0xFFFF0000;

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			bgSprite.scaleX = this.width + offsetX * 2 + 10;
			bgSprite.scaleY = this.height + offsetY * 2 + 3;
		}

		cacheCount = currentCount;

		bgSprite.x = this.x - offsetX;
		bgSprite.y = this.y - offsetY;
	}
}
