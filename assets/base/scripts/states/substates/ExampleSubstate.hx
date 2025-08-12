import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextAlign;

var bg:FlxSprite;
var closeText:FlxText;

var closing = false;

function create():Void
{
	closing = false;
	
	add(bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK));
	bg.scale.set(FlxG.width, FlxG.height);
	bg.screenCenter();
	bg.alpha = 0;
	FlxTween.tween(bg, {alpha: .65}, 0.2, {ease: FlxEase.expoInOut});

	elgato = new FlxSprite().loadGraphic(Paths.image('extra/el'));
	elgato.screenCenter();
	elgato.updateHitbox();
	elgato.y += 25;
	elgato.alpha = 0;
	add(elgato);
	FlxTween.tween(elgato, {alpha: 1}, 0.2, {ease: FlxEase.expoInOut});

	closeText = new FlxText();
	closeText.setFormat(Paths.font("Futura-CondensedExtraBold.otf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER);
	closeText.text = "Press enter/space to leave!!!";
	closeText.x = FlxG.width - closeText.width - 10;
	closeText.y = FlxG.height - closeText.height - 10;
	closeText.updateHitbox();
	closeText.alpha = 0;
	add(closeText);
	FlxTween.tween(closeText, {alpha: 1}, 0.2, {ease: FlxEase.expoInOut});
}

function onClose() : Void
	trace('closed');
function onClosePost() : Void
	trace('post closed');

function update(elapsed:Float):Void
{
	if (FlxG.keys.justPressed.ENTER && !closing)
	{
		closing = true;
		if (bg != null)
			FlxTween.tween(bg, {alpha: 0}, .2, {ease: FlxEase.expoOut});
		if (closeText != null)
			FlxTween.tween(closeText, {alpha: 0}, .2, {ease: FlxEase.expoOut, startDelay: .2});

		new FlxTimer().start(.45, _ -> close());
	}
}
