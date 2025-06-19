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
	 * Used to uhh fix json maps.	
	 */
	public static function mapify<T>(v:Dynamic):Map<String, Dynamic>
	{
		final animPrefixes:StringMap<Dynamic> = new StringMap<Dynamic>();
		for (field in Reflect.fields(v))
			animPrefixes.set(field, Reflect.field(v, field));
		return animPrefixes;
	}

	@:noUsing public static inline function getFPSRatio(ratio:Float):Float
	{
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
	}

	@:noUsing public static inline function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
	{
		return FlxMath.lerp(v1, v2, getFPSRatio(ratio));
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

	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):T
	{
		return (v == null || MathsAddon.isNaN(v)) ? defaultValue : v;
	}

	static var _mousePoint:FlxPoint = new FlxPoint();
	static var _objPoint:FlxPoint = new FlxPoint();

	public static function mouseOverlapping<T:flixel.FlxObject>(obj:T, ?mousePoint:FlxPoint, ?camera:flixel.FlxCamera):Bool
	{
		camera ??= obj.camera;
		if (mousePoint == null)
		{
			mousePoint = _mousePoint;
			FlxG.mouse.getScreenPosition(camera, mousePoint);
		}
		{
			obj.getScreenPosition(_objPoint, camera);
			return FlxMath.pointInCoordinates(mousePoint.x, mousePoint.y, _objPoint.x, _objPoint.y, obj.width, obj.height);
		}
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if (FileSystem.exists(path))
			daList = File.getContent(path).trim().split('\n');
		#else
		if (Assets.exists(path))
			daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if (color.startsWith('0x'))
			color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
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

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);

		return dumbArray;
	}

	public static function browserLoad(site:String)
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
	inline public static function get_savePath():String
		return '${FlxG.stage.application.meta.get('company')}/${FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
}
