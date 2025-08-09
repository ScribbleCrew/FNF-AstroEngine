package funkin.backend.assets;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import flash.media.Sound;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;

@:final
class AssetsPaths
{
	public static final JSON_REGEX:EReg = ~/\.json$/i;
	public static final HX_REGEX = ~/\.hx$/i;
	public static final IMAGE_REGEX = ~/\.(jpe?g|png|jpeg?)$/i;
	public static final LUA_REGEX = ~/\.lua$/i;
	public static final SOUND_REGEX = #if web ~/\.mp3$/i #else ~/\.ogg$/i #end;

	public static final FLXGRAPHIC_KEY:String = "TwG|";

	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:String, ?modsAllowed:Bool = true):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			final modPath = Paths.modFolders('${library != null ? '$library/' : ""}$file');
			if (FileSystem.exists(modPath))
				return modPath;
		}
		#end

		if (library != null)
		{
			final folderPath = Paths.getFolderPath(file, library);
			if (FileSystem.exists(folderPath) || Assets.exists(folderPath, type))
				return folderPath;
		}

		if (Paths.currentLevel != null && Paths.currentLevel != "shared")
		{
			final levelPath = Paths.getFolderPath(file, Paths.currentLevel);
			if (FileSystem.exists(levelPath) || Assets.exists(levelPath, type))
				return levelPath;
		}

		final sharedPath = Paths.getSharedPath(file);
		if (FileSystem.exists(sharedPath) || Assets.exists(sharedPath, type))
			return sharedPath;

		return file; // fallback (probably will error if used)
	}

	public static function font(key:String, ?library:String) : String {
		if(library != null) return Paths.getFolderPath('fonts/$key', library);
		#if MODS_ALLOWED
		final file:String = Paths.modsFont(key);
		if (FileSystem.exists(file)) return file;
		#end
		return 'assets/fonts/$key';
	}

	public static inline function fileExists(key:String, ?type:AssetType, ?allowMods:Bool = true, ?library:String) : Bool  {
		final path : String = getPath(key, type, library, allowMods);
		#if MODS_ALLOWED if (FileSystem.exists(Paths.mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(Paths.mods(key))) return true; #end
		return FileSystem.exists(path) || Assets.exists(path);
	}

	public static inline function getContent(key:String, ?library:String, ?allowMods:Bool):String
		return _getContent(getPath(key, TEXT, library, allowMods));

	 static inline function _getContent(key:String):String {
		#if MODS_ALLOWED
		var modPath = Paths.mods('${Mods.currentModDirectory}/$key');
		if (FileSystem.exists(modPath))
			return File.getContent(modPath);

		modPath = Paths.mods(key);
		if (FileSystem.exists(modPath))
			return File.getContent(modPath);
		#end

		return FileSystem.exists(key) ? File.getContent(key) : Assets.exists(key) ? Assets.getText(key) : null;
	}
}
