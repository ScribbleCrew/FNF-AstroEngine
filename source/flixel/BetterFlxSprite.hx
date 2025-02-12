package flixel;

/**
* Used to set data inside a flxsprite.
*/
class BetterFlxSprite extends flixel.FlxSprite
{
	public var data:Map<String,Dynamic> = new Map<String,Dynamic>();

	public function new(?X:Float = 0, ?Y:Float = 0, ?FlxGraphicAsset:flixel.system.FlxAssets.FlxGraphicAsset):Void
	{
		super(X, Y, FlxGraphicAsset);
	}
}
