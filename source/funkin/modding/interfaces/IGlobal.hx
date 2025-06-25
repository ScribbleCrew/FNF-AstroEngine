package funkin.modding.interfaces;

interface IGlobal {
	public function call(functionName:String, ?args:Array<Dynamic>, ?ignoreStops:Null<Bool>, ?exclusions:Array<String>, ?excludeValues:Array<Dynamic>, ?context:HScript.ScriptContext):Dynamic;
    public function set(variable:String, arg:Dynamic, ?exclusions:Array<String>):Void;
}