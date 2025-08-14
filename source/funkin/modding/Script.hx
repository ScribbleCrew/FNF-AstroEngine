package funkin.modding;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import funkin.modding.Script.ScriptType;
import openfl.utils.Assets;
import haxe.io.Path;

enum ScriptType // use interfaces instead -- TODO
{
	HSCRIPT;
	PYTHON;
	LUA;
	BOTH; // DO NOT DELETE ME
	DUMMY;
}

class Script implements IFlxDestroyable {
	public var type(get, never):ScriptType;

	@:dox(hide) @:noCompletion function get_type():ScriptType
		return DUMMY;

	public var active:Bool = false;
	var __path:String = '';

	public function new(?path:String):Void { __path = path; active = true; }

	/**
	 * [Description] Creates a new script instance based on the provided path.
	 * @param path The path to the script file.
	 * @return A new script instance, or a DummyScript if script extensions are not recognized.
	 * @see funkin.modding.Script.checkScriptExtensions
	 */
	public static function create(path:String):Dynamic {
		if (Assets.exists(path)) {
			return switch Path.extension(path).toLowerCase() {
				case "hscript" | "hx" | "hsc" | "hxs":
					new HScript(null, path);
				case "lua" | "luau":
					new FunkinLua(path);
				default:
					new DummyScript(path);
			}
		}
		return null;
	}

	// so they'll actually work...
	public function set(name:String, param:Dynamic):Void {}

	/**
	 * [Description] Sets the parent of the script.
	 * @param parent The parent object to set for the script.
	 * @return Dynamic
	 */
	public function setParent(parent:Dynamic):Dynamic { return -1;}

	/**
	 * [Description] Stops the script execution.
	 * It can be overridden in subclasses to implement custom stop behavior.
	 * @return Void
	 */
	public function stop():Void {}

	/**
	 * [Description] Gets a variable from the script.
	 * If the variable does not exist, it will return `null`. 
	 * @param id The identifier of the variable to retrieve.
	 * @return Dynamic
	 */
	public function get(id:String):Dynamic { return null; }

	/**
	 * [Description] Runs the script.
	 * @param args Optional arguments to pass to the script when running.
	 * @return Dynamic
	 */
	public function run(?args:Array<Dynamic>):Dynamic { return null;}

	/**
	 * [Description] Calls a function in the script with the provided parameters.
	 * @param function The name of the function to call.
	 * @param parameters Optional parameters to pass to the function.
	 * @return Dynamic
	 */
	public function call(id:String, ?parameters:Array<Dynamic>):Dynamic { return null; } // should we even have the stop stuff here? 

	/**
	 * [Description] Destroys the script instance.
	 */
	public function destroy():Void { active = false; }


	static var __extensions:Map<String, Array<String>> = new Map<String, Array<String>>();
	static function __setupScriptExt():Void { // TODO: use regex instead of strings
		#if LUA_ALLOWED __extensions.set('lua', [".lua", ".funkinlua"]); #end
		#if HSCRIPT_ALLOWED __extensions.set('haxe', [".hx", ".hxc", ".hscript" /* why would anyone need this... */]); /* funi __extensions */ #end
	}

	/**
	 * Checks if a given file name has a valid script file extension.
	 *
	 * If a `type` is provided, only __extensions for that script type will be checked.
	 * Otherwise, all registered script __extensions are considered.
	 *
	 * @param file The file name (including extension) to check.
	 * @param type Optional script type to check against (e.g. `"lua"` or `"haxe"`).
	 * @return `true` if the file matches a valid extension for the given (or any) type, `false` otherwise.
	 */
	#if GLOBAL_SCRIPT @:allow(funkin.modding.GlobalScript) #end
	public static function checkScriptExtensions(file:String, ?type:String):Bool {
		// Extension check loop
		for (typeKey in __extensions.keys()) {
			// If 'type' is provided, check only that specific type
			if (type != null && type != typeKey)
				continue;

			// Check __extensions for the current type
			for (ext in __extensions.get(typeKey)) {
				// Check if the file ends with the extension
				if (file.endsWith(ext))
					return true;
			}
		}

		// If the extension isn't found
		return false;
	}
} // duh
