package funkin.modding;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import funkin.modding.Script.ScriptType as TScript;

enum ScriptType // use interfaces instead -- TODO
{
	HSCRIPT;
	PYTHON;
	LUA;
	BOTH; // DO NOT DELETE ME
}

class Script implements IFlxDestroyable
{
	public var type(get, never):ScriptType;

	@:dox(hide) @:noCompletion
	function get_type():ScriptType
		return HSCRIPT;

	public var active:Bool = false;

	public function new():Void
	{
		active = true;
	}

	// so they'll actually work...
	public function set(name:String, param:Dynamic):Void
	{
	}

	public function setParent(e:Dynamic)
	{
	}

	public function stop()
	{
	}

	public function get(blah:String):Dynamic
	{
		return null;
	}

	public function run(?args:Array<Dynamic>):Dynamic
	{
		return null;
	}

	public function call(functionName:String, ?funcArgs:Array<Dynamic>):Dynamic // should we even have the stop stuff here?
	{
		return null;
	}

	public function destroy()
	{
		active = false;
	}

	

	/**
	 * Checks if a given file name has a valid script file extension.
	 *
	 * If a `type` is provided, only extensions for that script type will be checked.
	 * Otherwise, all registered script extensions are considered.
	 *
	 * @param file The file name (including extension) to check.
	 * @param type Optional script type to check against (e.g. `"lua"` or `"haxe"`).
	 * @return `true` if the file matches a valid extension for the given (or any) type, `false` otherwise.
	 */
	#if GLOBAL_SCRIPT @:allow(funkin.modding.GlobalScript) #end
	static function checkScriptExtensions(file:String, ?type:String):Bool
	{
		#if LUA_ALLOWED extensions.set('lua', [".lua", ".funkinlua"]); #end
		#if HSCRIPT_ALLOWED extensions.set('haxe', [".hx", ".hxc", ".hscript" /* why would anyone need this... */]); /* funi extensions */ #end
		
		// Extension check loop
		for (typeKey in extensions.keys())
		{
			// If 'type' is provided, check only that specific type
			if (type != null && type != typeKey)
				continue;

			// Check extensions for the current type
			for (ext in extensions.get(typeKey))
			{
				// Check if the file ends with the extension
				if (file.endsWith(ext))
					return true;
			}
		}

		// If the extension isn't found
		return false;
	}
} // duh
