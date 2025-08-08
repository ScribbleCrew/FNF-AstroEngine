package funkin.modding.lua.functions;

#if LUA_ALLOWED
import openfl.utils.Assets;

class FileFunctions
{
	public static function implement(funk:FunkinLua)
	{
		final lua:State = funk.lua;

		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false)
		{
			#if MODS_ALLOWED
			if (absolute)
				return FileSystem.exists(filename);

			return FileSystem.exists(Paths.getPath(filename, TEXT));
			#else
			if (absolute)
				return Assets.exists(filename, TEXT);

			return Assets.exists(Paths.getPath(filename, TEXT));
			#end
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try
			{
				#if MODS_ALLOWED
				if (!absolute)
					File.saveContent(Paths.mods(path), content);
				else
				#end
				File.saveContent(path, content);

				return true;
			}
			catch (e:Dynamic)
			{
				FunkinLua.luaTrace("saveFile: Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String, ?ignoreModFolders:Bool = false, ?absolute:Bool = false)
		{
			try
			{
				var lePath:String = path;
				if (!absolute)
					lePath = Paths.getPath(path, TEXT, !ignoreModFolders);
				if (FileSystem.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			}
			catch (e:Dynamic)
			{
				FunkinLua.luaTrace("deleteFile: Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getTextFromFile",
			(path:String, ?ignoreModFolders:Bool = false) -> return funkin.backend.assets.AssetsPaths.getContent(path, !ignoreModFolders));

		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String)
		{
			var list:Array<String> = [];
			#if sys
			if (FileSystem.exists(folder))
				for (folder in FileSystem.readDirectory(folder))
					if (!list.contains(folder))
						list.push(folder);
			#end
			return list;
		});
	}
}
#end
