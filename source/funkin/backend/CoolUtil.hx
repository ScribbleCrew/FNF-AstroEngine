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
	 * Returns a string representation of a size, following this format: `1.02 GB`, `134.00 MB`
	 * @param size Size to convert to string
	 * @return String Result string representation
	 */
	public static function getSizeString(size:Float):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	/**
	 * Returns the class in question's path e.g `funkin.backend.CoolUtil`
	 * @param class 
	 * @return String 
		return Type.getClassName(Type.getClass(class))
	 */
	public static function getClassPath(_class:Dynamic):String 
		return Type.getClassName(Type.getClass(_class));

	/**
	 * Returns the class in question's name e.g `CoolUtil`
	 * @param class 
	 * @return String
		return getClassPath(class).split(".").pop()
	 */
	public static function getClassName(_class:Dynamic):String
		return getClassPath(_class).split(".").pop();

	/**
	 * Add several zeros at the beginning of a string, so that `2` becomes `02`.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
	 * Used to uhh fix json maps.	
	 */
	public static function objectToMap<T>(v:Dynamic):Map<String, Dynamic>
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

	@:noUsing public static function coolTextFile(path:String):Array<String>
	{
		var betterehh:String = '';
		if (OpenFlAssets.exists(path)) betterehh = OpenFlAssets.getText(path);
		#if sys if (FileSystem.exists(path)) betterehh = File.getContent(path); #end
		
		var trim:String;
		return [for(line in betterehh.split("\n")) if ((trim = line.trim()) != "" && !trim.startsWith("#")) trim];
	}

	inline public static function colorFromString(color:String):FlxColor
		return FlxColor.fromString((color = ~/[\t\n\r]/.split(color).join('').trim()).startsWith('0x') ? color.substring(color.length - 6) : color) 
			?? FlxColor.fromString('#$color') 
			?? FlxColor.WHITE;


	public static function listFromString(string:String):Array<String>
		return [for (line in string.trim().split('\n')) line.trim()];

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

	public static function range(max:Int, ?min = 0):Array<Int>
		return [for (i in min...max) i];

	@:noUsing public static function browserLoad(site:String) : Void
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
