import flixel.FlxSprite;

var bg:FlxSprite;
var closeText:FlxText;

function create():Void
{
	bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.alpha = 0;
	bg.screenCenter(FlxAxes.X);
	add(bg);
	FlxTween.tween(bg, {alpha: .65}, 0.2, {ease: FlxEase.expoOut});

	closeText = new FlxText().setFormat(Paths.font("Futura-CondensedExtraBold.otf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER);
	closeText.text = "Press enter/space to leave!!!";
	closeText.x = FlxG.width - closeText.width - 10;
	closeText.y = FlxG.height - closeText.height - 10;
	closeText.updateHitbox();
	closeText.alpha = 0;
	add(closeText);
	FlxTween.tween(closeText, {alpha: 1}, 0.2, {ease: FlxEase.expoOut});
}

function onClose() : Void
	trace('closed');
function onClosePost() : Void
	trace('post closed');

function update(elapsed:Float):Void
{
	if (FlxG.keys.justPressed.ENTER)
	{
		if (bg != null)
			FlxTween.tween(bg, {alpha: 0}, .2, {ease: FlxEase.expoOut});
		if (closeText != null)
			FlxTween.tween(closeText, {alpha: 0}, .2, {ease: FlxEase.expoOut, startDelay: .2});

		new FlxTimer().start(.45, _ -> close());
	}
}
