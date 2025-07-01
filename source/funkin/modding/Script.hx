package funkin.modding;

enum ScriptType
{
	HSCRIPT;
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

	public function get(blah:String):Dynamic
	{
		return null;
	}

	public function call(functionName:String, ?funcArgs:Array<Dynamic>):Dynamic
	{
		return null;
	}

	public function destroy()
	{
		active = false;
	}
} // duh
