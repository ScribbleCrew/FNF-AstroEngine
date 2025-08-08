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
	public static final JSON_SUFFEX:String = ".json";
	public static final FLXGRAPHIC_KEY:String = "TwG|";

	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentfolder:String, ?modsAllowed:Bool = true):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			final modPath = Paths.modFolders('${parentfolder != null ? '$parentfolder/' : ""}$file');
			if (FileSystem.exists(modPath))
				return modPath;
		}
		#end

		if (parentfolder != null)
		{
			final folderPath = Paths.getFolderPath(file, parentfolder);
			if (FileSystem.exists(folderPath) || OpenFlAssets.exists(folderPath, type))
				return folderPath;
		}

		if (Paths.currentLevel != null && Paths.currentLevel != "shared")
		{
			final levelPath = Paths.getFolderPath(file, Paths.currentLevel);
			if (FileSystem.exists(levelPath) || OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		final sharedPath = Paths.getSharedPath(file);
		if (FileSystem.exists(sharedPath) || OpenFlAssets.exists(sharedPath, type))
			return sharedPath;

		if (FileSystem.exists(file) || OpenFlAssets.exists(file, type))
			return file;

		return file; // fallback (probably will error if used)
	}

	@:noCompletion static function __trim(key:String, ?library:String, ?allowMods:Bool):String
	{
		final path:String = getPath(key, library, allowMods);
		return (library != null && library.length > 0 && path.indexOf(":") > -1) ? path.substr(path.indexOf(":") + 1) : path;
	}

	public static function fileExists(key:String, ?library:String, ?allowMods:Bool):Bool
	{
		#if MODS_ALLOWED if (FileSystem.exists(Paths.mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(Paths.mods(key)))
			return true; #end
		return FileSystem.exists(__trim(key, library, allowMods)) || Assets.exists(getPath(key, library, allowMods));
	}

	public static function getContent(key:String, ?library:String, ?allowMods:Bool):String
	{
		final path:String = getPath(key, TEXT, library, allowMods);
		final fsPath:String = __trim(key, library, allowMods);
		return FileSystem.exists(fsPath) ? File.getContent(fsPath) : (Assets.exists(path) ? Assets.getText(path) : null);
	}
}
