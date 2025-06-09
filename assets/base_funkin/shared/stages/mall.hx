package stages;

// TODO: optim

import objects.MallCrowd;
import flixel.util.FlxColor;

using funkin.backend.utils.ObjectUtils;

var upperBoppers:BGSprite;
var bottomBoppers:MallCrowd;
var santa:BGSprite;

var lights_off_sound = null;

function onCreate() : Void
{
	var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	addHxObject(bg);

	if (!ClientPrefs.data.lowQuality)
	{
		upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
		upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		upperBoppers.updateHitbox();
		addHxObject(upperBoppers);

		var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
		bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		bgEscalator.updateHitbox();
		addHxObject(bgEscalator);
	}

	addHxObject(new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40));
	addHxObject(bottomBoppers = new MallCrowd(-300, 140));
	addHxObject(new BGSprite('christmas/fgSnow', -600, 700));
	addHxObject(santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']));
    
	lights_off_sound = Paths.sound('Lights_Shut_off');// preloads
	setDefaultGF('gf-christmas');

	if (PlayState.isStoryMode && !PlayState.seenCutscene) endCallback = eggnogEndCutscene;
}

function onCountdownTick(count, num:Int)
	everyoneDance();

function onBeatHit()
	everyoneDance();

function onEventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) : Void
{
	switch (eventName)
	{
		case "Hey!":
			switch (value1.toLowerCase().trim())
			{
				case 'bf' | 'boyfriend' | '0':
					return;
			}
			bottomBoppers.animation.play('hey', true);
			bottomBoppers.heyTimer = flValue2;
	}
}

function everyoneDance() : Void
{
	if (!ClientPrefs.data.lowQuality) upperBoppers.dance(true);

	bottomBoppers.dance(true);
	santa.dance(true);
}

function eggnogEndCutscene() : Void
{
	final nextSong = PlayState.storyPlaylist[1];

	if (nextSong == null)
	{
		endSong();
		return;
	}

	if (Paths.formatToSongPath(nextSong) == 'winter-horrorland')
	{
		FlxG.sound.play(lights_off_sound ?? Paths.sound('Lights_Shut_off')); // hehe

		final blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom);
		blackShit.makeSolid(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackShit.scrollFactor.set();
		add(blackShit);

		camHUD.visible = false;

		inCutscene = true;
		canPause = false;

		new FlxTimer().start(1.5, (tmr:FlxTimer) -> endSong());
		return;
	}

	endSong();
}
