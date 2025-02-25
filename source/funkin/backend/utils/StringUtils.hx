package funkin.backend.utils;

class StringUtils
{
	/**
	 * Capitalizes Text
	 * @param x Input
	 * @return Converted String 
	**/
	public inline static function capitalize(x:String):String
	{
		return x.split(" ").map(s -> s.charAt(0).toUpperCase() + s.substr(1)).join(" ");
	}

	/**
	 * Resets Map to a value of your choosing
	 * @param map Input
	 * @param resetVal Optional the reset value
	 * @return Resetted Map
	**/
	public static function resetMap(map:Map<Dynamic, Dynamic>, ?resetVal:Dynamic = false)
	{
		for (i in map.keys())
			map.set(i, resetVal);
	}
	// bruh
	public static inline function resetArray(x:Array<Dynamic>)
		return x = [];
}
