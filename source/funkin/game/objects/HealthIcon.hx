package funkin.game.objects;

import flixel.graphics.FlxGraphic;

class HealthIcon extends FlxSprite
{
	@:noCompletion private var _isPlayer:Bool = false;
	@:noCompletion private var _iconOffsets:Array<Float> = [0, 0];
	@:noCompletion private var _character:String = '';

	@:isVar
	public var character(get,never):String;
	@:dox(hide) @:noCompletion private inline function get_character():String
		return _character;
	
	public var sprTracker:FlxSprite;
	public var autoAdjustOffset:Bool = true;

	public function new(char:String = 'face', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		this._isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	public function changeIcon(char:String, ?allowGPU:Bool = true):Void
	{
		if (this._character != char)
		{
			this._character = char;

			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-face';

			final graphic:FlxGraphic = Paths.image(name, allowGPU);
			loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
			_iconOffsets[0] = (width - 150) / 2;
			_iconOffsets[1] = (height - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1], 0, false, _isPlayer);
			animation.play(char);

			antialiasing = char.endsWith('-pixel') ? false : ClientPrefs.data.antialiasing;
		}
	}

	override function update(elapsed:Float) : Void
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	override function updateHitbox() : Void
	{
		super.updateHitbox();

		if (autoAdjustOffset)
		{
			offset.x = _iconOffsets[0];
			offset.y = _iconOffsets[1];
		}
	}
}
