package funkin.backend;

/**
	Structure For Main Menu Versions

	@param name Name / Astro Engine v
	@param version Version / 0.0.0
	@param offset Offsets / FlxPoint.get(X,Y)
**/
typedef MenuVersionStructure =
{
	// Name
	var name:Null<String>;
	// Version
	var version:Null<String>;
	// Offsets | XY
	@:optional var offset:FlxPoint;
}

/**
	Structure For Versions

	@param name Asset Name / menu_$name
	@param state FlxState / FlxSubState
	@param link Website Link
**/
typedef MenuItemsStructure =
{
	// Name
	var name:Null<String>;

	// State
	@:optional var state:haxe.extern.EitherType<flixel.FlxSubState, flixel.FlxState>;

	// Website Link
	@:optional var link:Null<String>;
}