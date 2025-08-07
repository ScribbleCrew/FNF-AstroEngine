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

class AssetsPaths
{
	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentfolder:String, ?modsAllowed:Bool = true):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			final modPath =  Paths.modFolders('${parentfolder != null ? '$parentfolder/' : ""}$file');
			if (FileSystem.exists(modPath))
				return modPath;
		}
		#end
		if (parentfolder != null)
		{
			final parentPath = Paths.getFolderPath(file, parentfolder);

			if (FileSystem.exists(parentPath))
				return parentPath;
			if (Assets.exists(parentPath, type))
				return parentPath;
		}
		if (Paths.currentLevel != null && Paths.currentLevel != 'shared')
		{
			final levelPath = Paths.getFolderPath(file, Paths.currentLevel);
			if (FileSystem.exists(levelPath))
				return levelPath;
			if (Assets.exists(levelPath, type))
				return levelPath;
		}
		final sharedPath = Paths.getSharedPath(file);

		if (FileSystem.exists(sharedPath))
			return sharedPath;
		if (Assets.exists(sharedPath, type))
			return sharedPath;

		throw 'File not found: $file';
	}

    static function fsPath(key:String, ?library:String) : String {
        final path = getPath(key, library);
        return (library != null && library.length > 0 && path.indexOf(":") > -1) ? path.substr(path.indexOf(":") + 1) : path;
    }

	public static function fileExists(key:String, ?library:String):Bool
	{
		if (FileSystem.exists(fsPath(key, library))) return true;
		return Assets.exists(getPath(key, library));
	}

	/**
	 * This function allows you to get the content from a embedded or a non embedded file.
	 * @param key 
	 * @param library 
	 * @param allowMods 
	 * @return String
	 */
	public static function getContent(key:String, ?library:String, ?allowMods:Bool):String
	{
		final path:String = getPath(key, library, allowMods ?? true);
		final fsPath:String = (library != null && library.length > 0 && path.indexOf(":") > -1) ? path.substr(path.indexOf(":") + 1) : path;

		if (FileSystem.exists(fsPath))
			return File.getContent(fsPath);
		else if (Assets.exists(path))
			return Assets.getText(path);
		else
			throw 'File not found: $path';
	}
}
