package funkin.backend;

import haxe.ds.StringMap;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

class CoolUtil
{
	/**
	 * [Description] Check if a sound is valid, meaning it has a buffer and a transform.
	 * @param sound This parameter can be any sound type, such as `openfl.media.Sound` or `flixel.sound.FlxSound`.
	 * @return Bool Returns true if the sound is valid, false otherwise.
	 */
	@:access(flixel.sound.FlxSound)
	@:access(openfl.media.Sound.__buffer)
	public static function isValid<T:FlxSound>(s:T):Bool
		return s != null && s._sound?.__buffer != null && s?._transform != null;

	/**
	 * [Description] Gets the size of a file in bytes and converts it to a human-readable string.
	 * @param size Size in bytes to convert.
	 * @return String Returns a string representation of the size, e.g. `1.02 GB`, `134.00 MB`
	 */
	@:noUsing public static function getSizeString(size:Float):String
	{
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while (rSize > 1024 && label < labels.length - 1)
		{
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	@:dox(hide) @:noCompletion static var __mousePoint:FlxPoint = new FlxPoint();
	@:dox(hide) @:noCompletion static var __objPoint:FlxPoint = new FlxPoint();

	/**
	 * [Description] Checks if the mouse is overlapping with a given object.
	 * @param obj The object to check for mouse overlap.
	 * @param mousePoint If not provided, it will use the current mouse position.
	 * @param camera  If not provided, it will use the object's camera.
	 * @return Bool Returns true if the mouse is overlapping with the object, false otherwise.
	 */
	public static function mouseOverlapping<T:flixel.FlxObject>(obj:T, ?mousePoint:FlxPoint, ?camera:flixel.FlxCamera)
	{
		camera ??= obj.camera;
		mousePoint ??= FlxG.mouse.getScreenPosition(camera, __mousePoint);
		obj.getScreenPosition(__objPoint, camera);
		return FlxMath.pointInCoordinates(mousePoint.x, mousePoint.y, __objPoint.x, __objPoint.y, obj.width, obj.height);
	}

	/**
	 * [Description] Returns the class in question's path e.g `funkin.backend.CoolUtil`
	 * @param class  Dynamic class to get the path of.
	 * @return String Returns the class path.
	 */
	@:noUsing public static function getClassPath(_class:Dynamic):String
		return Type.getClassName(Type.getClass(_class));

	/**
	 * [Description] Returns the class in question's name e.g `CoolUtil`
	 * @param class Dynamic class to get the name of.
	 * @return String Returns the class name.
	 */
	@:noUsing public static function getClassName(_class:Dynamic):String
		return getClassPath(_class).split(".").pop();

	/**
	 * [Description] Add several zeros at the beginning of a string, so that `2` becomes `02`.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	@:noUsing public static inline function addZeros(str:String, num:Int)
	{
		while (str.length < num)
			str = '0${str}';
		return str;
	}

	/**
	 * [Description] Converts an object to a map.
	 * @param v The object to convert.
	 * @return Map<String, Dynamic> Returns a map with the object's fields and values.
	 */
	@:noUsing public static inline function objectToMap<T>(v:Dynamic):Map<String, Dynamic>
	{
		final animPrefixes:StringMap<Dynamic> = new StringMap<Dynamic>();
		for (field in Reflect.fields(v))
			animPrefixes.set(field, Reflect.field(v, field));
		return animPrefixes;
	}

	/**
	 * [Description] Returns a ratio of the current FPS to the target FPS.
	 * @param ratio	 The ratio to calculate, usually between 0 and 1.
	 * @return Float Returns the ratio of the current FPS to the target FPS.
	 */
	@:noUsing public static inline function getFPSRatio(ratio:Float):Float
	{
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}

	/**
	 * [Description] Lerps between two values based on the current FPS ratio.
	 * @param a  The first value to lerp from.
	 * @param b  The second value to lerp to.
	 * @param ratio  The ratio to calculate, usually between 0 and 1.
	 * @return Float Returns the lerped value between `a` and `b` based on the current FPS ratio.
	 */
	@:noUsing public static inline function fpsLerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, getFPSRatio(ratio));
	}

	/**
	 * Uhh
	 * @deprecated since ASTRO_N64	
	 */
	public static function checkStats(dataStore:String = 'Max Score', otheridk:Dynamic) // simple but effective
	{
		if (ClientPrefs.data.stats.get(dataStore) < otheridk)
			ClientPrefs.data.stats.set(dataStore, otheridk);

		ClientPrefs.saveSettings();
	}

	/**
	 * [Description] Returns a default value if the given value is null or NaN.
	 * @param v The value to check.
	 * @param defaultVal The default value to return if the given value is null or NaN.
	 * @return T
	 */
	public static inline function getDefault<T>(v:Null<T>, defaultVal:T):T
	{
		return (v == null || MathsAddon.isNaN(v)) ? defaultVal : v;
	}

	@:noUsing public static function coolTextFile(path:String):Array<String>
	{
		var betterehh:String = '';
		if (OpenFlAssets.exists(path))
			betterehh = OpenFlAssets.getText(path);
		#if sys
		if (FileSystem.exists(path))
			betterehh = File.getContent(path);
		#end

		var trim:String;
		return [
			for (line in betterehh.split("\n"))
				if ((trim = line.trim()) != "" && !trim.startsWith("#")) trim
		];
	}

	@:dox(hide) @:noCompletion static final __COLOR_REGEX:EReg = ~/[\t\n\r]/;
	/**
	 * [Description] Converts a string to a FlxColor.
	 * @param color The color string to convert.
	 * @return FlxColor Returns the FlxColor representation of the given color string.
	 */
	inline public static function colorFromString(color:String):FlxColor
		return FlxColor.fromString((color = __COLOR_REGEX.split(color)
			.join('')
			.trim()).startsWith('0x') ? color.substring(color.length - 6) : color) ?? FlxColor.fromString('#$color') ?? FlxColor.WHITE;

	@:noUsing public static function listFromString(string:String):Array<String>
		return [for (line in string.trim().split('\n')) line.trim()];

	@:noUsing inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel.alphaFloat > 0.05)
				{
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key => count in countByColor)
		{
			if (count >= maxCount)
			{
				maxCount = count;
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	@:noUsing public static function range(max:Int, ?min = 0):Array<Int>
		return [for (i in min...max) i];

	@:noUsing public static function browserLoad(site:String):Void
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	public static var savePath(get, default):String;

	@:access(flixel.util.FlxSave.validate)
	@:noUsing inline public static function get_savePath():String
		return '${FlxG.stage.application.meta.get('company')}/${FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
}
