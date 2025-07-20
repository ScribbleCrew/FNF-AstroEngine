package funkin.modding;

import funkin.modding.Script.ScriptType as TScript;

enum ScriptType // use interfaces instead -- TODO
{
	HSCRIPT;
	PYTHON;
	LUA;
	BOTH; // DO NOT DELETE ME
}

class Script
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
} // duh
