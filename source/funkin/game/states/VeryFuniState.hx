package funkin.game.states;

import flixel.util.FlxColorPastel;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import funkin.backend.system.MusicBeatState;
import funkin.backend.utils.Paths;



class AnimatedImageState extends MusicBeatState
{
	var background:FlxSprite;
	var title:FlxText;
	var index:FlxSprite;
	var stateReturn:FlxState;

	public function new(text:String, image:String, animPrefix:String, center:Bool, framerate:Int = 24, returnState:FlxState,
			color:FlxColor = FlxColorPastel.PASTELPINK)
	{
		super();//TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		FlxG.sound.music.stop();

		stateReturn = returnState;

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(background);

		title = new FlxText();
		title.setFormat(Paths.font("PhantomMuff.ttf"), 128, color, CENTER);
		title.text = text;
		title.y += 25;
		title.screenCenter(X);
		title.updateHitbox();
		add(title);

		index = new FlxSprite();
		index.frames = Paths.getSparrowAtlas(image);
		index.antialiasing = funkin.backend.utils.ClientPrefs.data.globalAntialiasing;
		index.animation.addByPrefix('instance', animPrefix, framerate, true);
		if (center)
			index.screenCenter();
		index.animation.play('instance');
		index.updateHitbox();
		add(index);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			MusicBeatState.switchState(stateReturn);
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}
}
