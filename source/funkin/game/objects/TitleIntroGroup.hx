package funkin.game.objects;

@:noCustomClass
class TitleIntroGroup extends FlxTypedSpriteGroup<flixel.FlxSprite>
{	
	/**
	 * For holding all sprites.
	 */
	var sprites:Array<Dynamic> = [];

	/**
	* Custom group for intro texts.	
	*/
	var customGroup:FlxTypedSpriteGroup<flixel.FlxSprite>;

	public function new():Void
	{
		super();
		var bg;
		add(bg = new FlxSprite().makeGraphic(1,1, FlxColor.BLACK));
		bg.scale.set(FlxG.width, FlxG.height);
		bg.screenCenter();

		add(customGroup = new FlxTypedSpriteGroup<flixel.FlxSprite>());
	}

	public function create(textArray:Array<String>, ?offset:FlxPoint):Void
	{
		offset??=FlxPoint.get();
		for (i in 0...textArray.length)
		{
			final money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset.y;
			money.x += offset.x;
			customGroup.add(money);
		}
	}

	/**
	 * Include text when create is a thing lol.	
	 *
	 * @param text the text lol
	 * @param offset (optional) text offset expressed as an FlxPoint
	 * @param ignoreGroupSpacing self-explanatory.
	 */
	public function include(text:String, ?offset:FlxPoint, ?ignoreGroupSpacing:Bool = false):Void
	{
		offset??=FlxPoint.get();
		if (this.customGroup != null)
		{
			final coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.x += offset.x;
			coolText.y += (ignoreGroupSpacing ? 0 : (customGroup.length * 60) + 200) + offset.y;
			customGroup.add(coolText);
		}
	}

	/**
	 * Clears all intro text and sprites.	
	 */
	public inline function empty():Void
	{
		// don't clear using FlxTypedSpriteGroup.
		// super.clear();
		customGroup.clear();
		while (sprites.length > 0)
		 	sprites.remove(sprites[0]);
		// while (customGroup.members.length > 0)
		// 	customGroup.remove(customGroup.members[0], true)
	}

	@:dox(hide) override function destroy():Void
	{
		while (sprites.length > 0)
		{
			var dude = sprites[0];
			sprites.remove(dude);
			dude = FlxDestroyUtil.destroy(dude);
		}
		super.destroy();
	}
}
