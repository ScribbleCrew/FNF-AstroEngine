package stages;


import funkin.backend.CoolUtil;
import objects.BackgroundGirls;
import funkin.game.states.substates.GameOverSubstate;
import flixel.util.FlxColor;
import funkin.game.objects.DialogueBox;

var bgGirls:BackgroundGirls;

function onCreate()
{
	final _song = PlayState.SONG;
	if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1)
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
	if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1)
		GameOverSubstate.loopSoundName = 'gameOver-pixel';
	if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1)
		GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
	if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1)
		GameOverSubstate.characterName = 'bf-pixel-dead';

	setDefaultGF('gf-pixel');

	switch (songName)
	{
		case 'senpai':
			FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		case 'roses':
			FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
	}
	if (PlayState.isStoryMode && !PlayState.seenCutscene)
	{
		if (songName == 'roses')
			FlxG.sound.play(Paths.sound('ANGRY'));
		initDoof();
		startCallback = schoolIntro;
	}

	var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
	addHxObject(bgSky);
	bgSky.antialiasing = false;

	var repositionShit = -200;

	var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
	addHxObject(bgSchool);
	bgSchool.antialiasing = false;

	var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
	addHxObject(bgStreet);
	bgStreet.antialiasing = false;

	var widShit = Std.int(bgSky.width * PlayState.daPixelZoom);
	if (!ClientPrefs.data.lowQuality)
	{
		var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
		fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		fgTrees.updateHitbox();
		addHxObject(fgTrees);
		fgTrees.antialiasing = false;
	}

	var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
	bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
	bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
	bgTrees.animation.play('treeLoop');
	bgTrees.scrollFactor.set(0.85, 0.85);
	addHxObject(bgTrees);
	bgTrees.antialiasing = false;

	if (!ClientPrefs.data.lowQuality)
	{
		var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
		treeLeaves.setGraphicSize(widShit);
		treeLeaves.updateHitbox();
		addHxObject(treeLeaves);
		treeLeaves.antialiasing = false;
	}

	bgSky.setGraphicSize(widShit);
	bgSchool.setGraphicSize(widShit);
	bgStreet.setGraphicSize(widShit);
	bgTrees.setGraphicSize(Std.int(widShit * 1.4));

	bgSky.updateHitbox();
	bgSchool.updateHitbox();
	bgStreet.updateHitbox();
	bgTrees.updateHitbox();

	if (!ClientPrefs.data.lowQuality)
	{
		bgGirls = new BackgroundGirls(-100, 190);
		bgGirls.scrollFactor.set(0.9, 0.9);
		addHxObject(bgGirls);
	}
}

function onBeatHit()
{
	if (bgGirls != null)
		bgGirls.dance();
}

// For events
function onEventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
{
	switch (eventName)
	{
		case "BG Freaks Expression":
			if (bgGirls != null)
				bgGirls.__remapAnimations();
	}
}

var songName(get, never):String;
function get_songName():String
	return PlayState.SONG.song.toLowerCase();


var doof:DialogueBox = null;

function initDoof()
{
	var dialogue:Array<String> = CoolUtil.coolTextFile(Paths.txt('songs'+ '/' + songName + '/' + songName + 'Dialogue'));
	doof = new DialogueBox(false, dialogue);
	doof.scrollFactor.set();
	doof.finishThing = () ->
	{
		camHUD.visible = true;
		startCountdown();
	};
	doof.nextDialogueThing = startNextDialogue;
	doof.skipDialogueThing = skipDialogue;
	doof.antialiasing = false;
	doof.camera = camOther;
}

function schoolIntro():Void
{
	inCutscene = true;
	camHUD.visible = false;
	var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
	black.scrollFactor.set();
	addHxObject(black);

	var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
	red.scrollFactor.set();

	var senpaiEvil:FlxSprite = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();
	senpaiEvil.x += 300;

	if (songName == 'roses' || songName == 'thorns')
	{
		remove(black);

		if (songName == 'thorns')
		{
			addHxObject(red);
			camHUD.visible = false;
		}
	}

	new FlxTimer().start(0.3, function(tmr:FlxTimer)
	{
		black.alpha -= 0.15;

		if (black.alpha > 0)
		{
			tmr.reset(0.3);
		}
		else
		{
			if (doof != null)
			{
				if (songName == 'thorns')
				{
					addHxObject(senpaiEvil);
					senpaiEvil.alpha = 0;
					new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
					{
						senpaiEvil.alpha += 0.15;
						if (senpaiEvil.alpha < 1)
						{
							swagTimer.reset();
						}
						else
						{
							senpaiEvil.animation.play('idle');
							FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
							{
								remove(senpaiEvil);
								remove(red);
								FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
								{
									add(doof);
									camHUD.visible = true;
								}, true);
							});
							new FlxTimer().start(3.2, function(deadTime:FlxTimer)
							{
								FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
							});
						}
					});
				}
				else
				{
					addHxObject(doof);
				}
			}
			else
				startCountdown();

			remove(black);
		}
	});
}
