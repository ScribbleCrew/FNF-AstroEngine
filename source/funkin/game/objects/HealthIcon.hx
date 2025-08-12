package funkin.game.objects;

import flixel.graphics.FlxGraphic;

class HealthIcon extends FlxSprite
{
	@:isVar
	public var character(get,never):String;
	@:dox(hide) @:noCompletion inline function get_character():String
		return __character;
	
	@:noCompletion var __iconOffsets:FlxPoint;
	@:noCompletion var __isPlayer:Bool = false;
	@:noCompletion var __character:String = '';

	/**
	 * [Description] The sprite to track the health icon.
	 */
	public var sprTracker:FlxSprite;

	/**
	 * [Description] If true, it will automatically adjust the offsets based on the icon size.
	 */
	public var autoAdjustOffset:Bool = true;

	public override function new(?char:String, ?isPlayer:Bool, ?allowGPU:Bool) : Void
	{
		__iconOffsets = new FlxPoint(0, 0);

		super();
		
		this.__isPlayer = (isPlayer ?? false);
		changeIcon(char ?? 'face', allowGPU ?? true);
		scrollFactor.set();
	}

	/**
	 * [Description] Changes the icon of the health icon.
	 * @param char The character name to change the icon to.
	 * @param allowGPU If true, it will allow GPU rendering for the icon.
	 * @return Void
	 */
	public function changeIcon(char:String, ?allowGPU:Bool = true):Void
	{
		if (this.__character != char)
		{
			this.__character = char;

			final __iconName : String = funkin.backend.CoolUtil.find(['icons/$char', 'icons/icon-$char', 'icons/icon-face'], opt -> Paths.fileExists('images/$opt.png', IMAGE)) ?? 'icons/icon-face';
			final __graphic:FlxGraphic = Paths.image(__iconName, allowGPU);
			this.loadGraphic(__graphic, true, Math.floor(__graphic.width / 2), Math.floor(__graphic.height));
			__iconOffsets.x = (width - 150) / 2;
			__iconOffsets.y = (height - 150) / 2;
			this.updateHitbox();

			// TODO: add a animation support.
			animation.add(char, [0, 1], 0, false, __isPlayer);
			animation.play(char);

			antialiasing = char.endsWith('-pixel') ? false : ClientPrefs.data.antialiasing;
		}
	}

	@:dox(hide) @:noCompletion override function update(elapsed:Float) : Void
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	@:dox(hide) @:noCompletion override function updateHitbox() : Void
	{
		super.updateHitbox();

		if (autoAdjustOffset)
		{
			offset.x = __iconOffsets.x;
			offset.y = __iconOffsets.y;
		}
	}
}
