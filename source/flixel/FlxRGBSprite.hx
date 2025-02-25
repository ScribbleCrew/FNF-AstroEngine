package flixel;

import funkin.game.objects.shaders.RGBPalette;
import funkin.game.objects.shaders.RGBPalette.RGBShaderReference;
import flixel.util.FlxColor;

class FlxRGBSprite extends flixel.FlxSprite
{
	var _rgbPalette:RGBPalette;
	var _rgbShaderReference:RGBShaderReference;

	@:isVar
	public var r(default, set):Int;
	@:dox(hide) inline function set_r(r:Int):Int
		return this.r = _rgbShaderReference.r = r;

	@:isVar
	public var g(default, set):Int;
	@:dox(hide) inline function set_g(g:Int):Int
		return this.g = _rgbShaderReference.g = g;

	@:isVar
	public var b(default, set):Int;
	@:dox(hide) inline function set_b(b:Int):Int
		return this.b = _rgbShaderReference.b = b;

	public function new(?X:Float = 0, ?Y:Float = 0, ?FlxGraphicAsset:flixel.system.FlxAssets.FlxGraphicAsset, ?RedChannel:FlxColor, ?GreenChannel:FlxColor,
			?BlueChannel:FlxColor):Void
	{
		super(X, Y, FlxGraphicAsset);

		_rgbShaderReference = new RGBShaderReference(this, _rgbPalette = new RGBPalette());

		if (RedChannel != null)
			_rgbShaderReference.r = RedChannel;
		if (GreenChannel != null)
			_rgbShaderReference.g = GreenChannel;
		if (BlueChannel != null)
			_rgbShaderReference.b = BlueChannel;
	}

	public override function destroy():Void
	{
		_rgbPalette = null;
		_rgbShaderReference = null;

		super.destroy();
	}
}
