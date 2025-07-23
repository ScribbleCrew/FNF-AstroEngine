package funkin.backend.utils;

import sys.FileSystem;

class FileUtil
{
	public static var originPath(get, null):String;

	@:noCompletion static function get_originPath():String
		return Sys.getCwd();

	
	public static inline function filename(string:String):String
	{
		final index:Int = string.lastIndexOf("/");
		return index == -1 ? string : string.substr(index + 1);
	}

	public static inline function validDirectory(path:String, ?origin:Bool = true):Bool
		return FileSystem.exists('${origin ? originPath : ''}$path');

	public static inline function isDir(path:String):Bool
		return FileSystem.isDirectory(path);

	public static function createDirectory(path:String, ?hidden:Bool = false, ?origin:Bool = true):Null<String>
	{
		#if sys
		try
		{
			final editedPath:String = /*#if (!windows) '${hidden ? '.':''}' +#end*/ '${origin ? originPath : ''}$path';

			if (!validDirectory(path))
				FileSystem.createDirectory('$editedPath'); // hopefully macos & linux shit
			#if windows
			if (hidden)
				Sys.command('attrib +h "$editedPath"');
			#end
			return editedPath;
		}
		catch (e:Dynamic)
			FlxG.log.error('CreateDir Error: $e');
		return null;
		#else
		errorMsg('createDirectory');
		return;
		#end
	}

	public static function deleteDirectory(path:String, ?origin:Bool = true):Void
	{
		#if sys
		try
			if (validDirectory(path))
				FileSystem.deleteDirectory('${origin ? originPath : ''}$path')
		catch (e:Dynamic)
			FlxG.log.error('delDir Error: $e');
		#else
		errorMsg('deleteDirectory');
		return;
		#end
	}

	public static function openFolder(path:String):Int
	{
		#if sys
		final _runProcess:String = #if windows "explorer" #elseif mac "open" #elseif linux "xdg-open" #else '' #end;
		final fullPath:String = haxe.io.Path.join([originPath, path]);
		return runProcess([#if windows "/c" #else "-c" #end, _runProcess, codeifyPath(fullPath)]);
		//	return Sys.command(runProcess, [fullPath.replace('/', '\\')]);
		#else
		errorMsg('openFolder');
		return;
		#end
	}

	public static function codeifyPath(path:String):String
		return path.replace('/', '\\');

	public static function runProcess(args:Array<String>):Int
	{
		#if sys
		final os = Sys.systemName();
		switch (os)
		{
			case "Windows":
				return Sys.command("cmd", args);
			case "Mac":
				return Sys.command("open", args);
			case "Linux":
				return Sys.command("xdg-open", args);
			default:
				trace("Unsupported OS: " + os);
		}
		#else
		trace("FileUtil.runProcess() is not supported on this platform.");
		#end
		return -1;
	}

	static function errorMsg(cmdName:String):Void
		FlxG.log.error('$cmdName isn\'t supported on your current platform, please try again later.');
}
