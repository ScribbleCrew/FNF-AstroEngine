package flixel.system;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.debug.FlxDebugger.GraphicWatch;
import openfl.display.Sprite;

using flixel.util.FlxStringUtil;
using flixel.util.FlxArrayUtil;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.display.DisplayObject;
import flixel.FlxG;
import flixel.system.debug.console.Console;
import flixel.system.debug.log.Log;
import flixel.system.debug.stats.Stats;
import flixel.system.debug.watch.Watch;
import flixel.system.debug.watch.Tracker;
import flixel.system.debug.completion.CompletionList;
import flixel.system.debug.log.BitmapLog;
import flixel.system.debug.interaction.Interaction;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxHorizontalAlign;

import openfl.display.Bitmap;

@:bitmap("embed/images/extra/kisser.png")
@:noCompletion class BoyKissers extends BitmapData {}

typedef GraphicStats = flixel.system.debug.FlxDebugger.GraphicStats;
/**
 * A Visual Studio-style "watch" window, for use in the debugger overlay.
 * Track the values of any public variable in real-time, and/or edit their values on the fly.
 */
class BoyKisser extends flixel.system.debug.Window
{
	#if FLX_DEBUG
	var entriesContainer:Sprite;
	var entriesContainerOffset:FlxPoint = FlxPoint.get(2, 15);

	public function new(closable:Bool = false)
	{
		super("Boykisser", new GraphicStats(0, 0), 0, 0, true, null, closable);

		entriesContainer = new Sprite();
		entriesContainer.x = entriesContainerOffset.x;
		entriesContainer.y = entriesContainerOffset.y;
		addChild(entriesContainer);

		var bmd:BitmapData = new BoyKissers(0, 0);
		var bitmap:Bitmap = new Bitmap(bmd);
		bitmap.x = 0;
		bitmap.y = 0;
		entriesContainer.addChild(bitmap);
	}
	#end
}
