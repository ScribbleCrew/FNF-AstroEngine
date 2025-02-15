package funkin.game.objects;

class TitleIntroGroup extends FlxTypedSpriteGroup<flixel.FlxSprite>
{
    public var newsgroundSprite:FlxSprite;

	private var customGroup:FlxTypedSpriteGroup<flixel.FlxSprite>;

	public function new()
	{
		super();
		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		customGroup = new FlxTypedSpriteGroup<flixel.FlxSprite>();
		add(customGroup);

		newsgroundSprite = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		newsgroundSprite.visible = false;
		newsgroundSprite.setGraphicSize(Std.int(newsgroundSprite.width * 0.8));
		newsgroundSprite.updateHitbox();
		newsgroundSprite.screenCenter(X);
		newsgroundSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(newsgroundSprite);
	}

	public function create(textArray:Array<String>, ?offset:Float = 0) : Void
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			customGroup.add(money);
		}
	}

	public function make(text:String, ?offset:Float = 0) : Void
	{
		if (this.customGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (customGroup.length * 60) + 200 + offset;
			customGroup.add(coolText);
		}
	}

	public function delete() : Void
	{
		while (customGroup.members.length > 0)
			customGroup.remove(customGroup.members[0], true);
	}
}
