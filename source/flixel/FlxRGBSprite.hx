package flixel;

import funkin.game.objects.shaders.RGBPalette;
import funkin.game.objects.shaders.RGBPalette.RGBShaderReference;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class FlxRGBSprite extends FlxSprite//stolen from twist engine lol
{
	var rgbPalette:RGBPalette;
	public var rgbShaderReference:RGBShaderReference;
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?RChannel:FlxColor, ?GChannel:FlxColor, ?BChannel:FlxColor)
	{
		super(X, Y, SimpleGraphic);
		rgbShaderReference = new RGBShaderReference(this, rgbPalette = new RGBPalette());
		if(RChannel != null) rgbShaderReference.r = RChannel;
		if(GChannel != null) rgbShaderReference.g = GChannel;
		if(BChannel != null) rgbShaderReference.b = BChannel;
	}
	public override function destroy()
	{
		rgbPalette = null;
		rgbShaderReference = null;
		super.destroy();
	}
}
