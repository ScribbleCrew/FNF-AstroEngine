package funkin.backend.utils;

class StringUtils
{

	public inline static function safeGet(map:Map<Dynamic, Dynamic>, arg, placeholder) {
		if(!map.exists(arg))
			map.set(arg,placeholder);
		return map.get(arg);
	}

	/**
	* Helps shorten strings.
	*
	* @param x uhh.
	* @param y uhh, values...
	* @returns Converted Phrase.	
	*/
	public inline static function substitute(x:String, y:Array<Dynamic> = null):String
		{			
			if(y != null)
				for (num => value in y)
					x = x.replace('{${num+1}}', value);
			return x;
		}

	/**
	 * Capitalizes Text
	 *
	 * @param x Input
	 * @return Converted String 
	*/
	public inline static function capitalize(x:String):String
		return x.split(" ").map(s -> s.charAt(0).toUpperCase() + s.substr(1)).join(" ");

	/**
	 * Resets Map to a value of your choosing
	 * @param map Input
	 * @param resetVal Optional the reset value
	 * @return Resetted Map
	*/
	@:deprecated('Deprecated in ASTRO_N64')
	public static function resetMap(map:Map<Dynamic, Dynamic>, ?resetVal:Dynamic = false)
		for (i in map.keys()) map.set(i, resetVal);

	// bruh
	// public static inline function empty<T:Array<Dynamic>>(x:T):T {
	// 	x.splice(0, x.length);
	// 	return x;
	// }
	
}
