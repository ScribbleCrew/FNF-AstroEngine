package game.objects;

import flixel.graphics.frames.FlxBitmapFont;
import funkin.game.objects.shaders.RGBPalette;

/**
 * Simple way to use angel code fonts i guess...
 * Allows spritesheets to be used instead of fonts.
 * This class is much better than FlxText.
 *
 * @author YourFriendOrbl
 */
class AngelFontText extends flixel.text.FlxBitmapText
{
	/**
	 * Sets the size of the text
	 */
	public var size(default, set):Float;

	/**
	 * `set_size()` literally sets the size.
	 */
	@:noCompletion private inline function set_size(size:Float)
	{
		/**
		 * `_angelCode` line height.
		 */
		final lineHeight:Float = _angelCode.lineHeight;

		/**
		 * `size` value divided by `lineHeight`.
		 */
		final scaleFactor:Float = size / lineHeight;

		/**
		 * set the scale to `scaleFactor`...
		 */
		this.scale.set(scaleFactor, scaleFactor);

		/**
		 * set `pos` to `this.getPosition()`.
		 */
		final pos:flixel.math.FlxPoint = this.getPosition();

		/**
		 * set the position to `pos.x` and `pos.y`.
		 */
		this.setPosition(pos.x, pos.y);

		/**
		 * call `updateHitbox()`.
		 */
		this.updateHitbox();

		/**
		 * return `this.size` equals `size`.
		 */
		return this.size = size;
	}

	/**
	 * RGB Shader Reference
	 */
	public var rgbShaderReference:RGBShaderReference;

	/**
	 * RGB Palette
	 */
	private var rgbPalette:RGBPalette;

	/**
	 * Bitmap Font Code.
	 */
	@:noCompletion private var _angelCode:FlxBitmapFont = null;

	/**
	 * Makes uhh idk
	 * @param   input_x     X Pos.
	 * @param   input_y     Y Pos.
	 * @param   input_fieldWidth     Field Width.
	 * @param   input_text     Text.
	 * @param   input_path     Font Path.
	 */
	public function new(input_x:Float, input_y:Float, input_fieldWidth:Int = null, input_text:String = "orbl goes crazy", input_path:String)
	{
		/**
		 * call `super()`.
		 */
		super();

		/**
		 * Set `font` and `_angelCode` to a new instance of `FlxBitmapFont` idk...
		 * and input `input_path` as a thing, idk...
		 */
		this.font = _angelCode = FlxBitmapFont.fromAngelCode('$input_path.png', '$input_path.xml');

		/**
		 * Set `text` to `input_text`.
		 */
		this.text = input_text;

		/**
		 * Call `updateHitbox`.
		 */
		this.updateHitbox();

		/**
		 * Checks if `input_fieldWidth` doesn't equal 0.
		 * Set `fieldWidth` to `input_fieldWidth`.
		 */
		if (input_fieldWidth != null)
			this.fieldWidth = input_fieldWidth;

		/**
		 * Set `x` to `input_x`.
		 */
		this.x = input_x;

		/**
		 * Set `y` to `input_y`.
		 */
		this.y = input_y;

		/**
		 * Set `autoSize` to false.
		 */
		this.autoSize = false;

		/**
		 * Create a new instance of `rgbShaderReference`.
		 */
		rgbShaderReference = new RGBShaderReference(this, rgbPalette = new RGBPalette());
	}

	/**
	 * Call `destory`
	 */
	public override function destroy()
	{
		/**
		 * Set the `rgbPalette` to null.
		 */
		rgbPalette = null;

		/**
		 * Set the `rgbShaderReference` to null.
		 */
		rgbShaderReference = null;

		/**
		 * Call `super.destory()`
		 */
		super.destroy();
	}
}
