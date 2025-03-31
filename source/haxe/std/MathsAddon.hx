package haxe.std;

@:pure class MathsAddon
{   
    /**
    * quantize 
    */
	inline public static function quantize(f:Float, snap:Float):Float
	{
		// changed so this actually works lol
		final m:Float = Math.fround(f * snap);
		return (m / snap);
	}

    /**
    * If `v` is not a number. 
    */
	public static inline function isNaN(v:Dynamic):Bool
	{
		return v is Float && Math.isNaN((v : Float));
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		return Math.floor(value * tempMult) / tempMult;
	}

	public static function coolLerp(base:Float, target:Float, ratio:Float):Float
	{
		return base + cameraLerp(ratio) * (target - base);
	}

	public static function cameraLerp(lerp:Float):Float
	{
		return lerp * (flixel.FlxG.elapsed / (1 / 60));
	}

	public inline static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}
}
