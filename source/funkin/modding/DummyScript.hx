package funkin.modding;

class DummyScript extends Script
{
	public var variables:Map<String, Dynamic> = [];

	public override function get(v:String)
	{
		return variables.get(v);
	}

	public override function set(v:String, v2:Dynamic)
	{
		return variables.set(v, v2);
	}

	public override function call(functionName:String, ?params:Array<Dynamic>):Dynamic
	{
		final __function = variables.get(functionName);
		if (Reflect.isFunction(__function))
			return Reflect.callMethod(null, __function, (params != null && params.length > 0) ? params : []);

		return null;
	}
}
