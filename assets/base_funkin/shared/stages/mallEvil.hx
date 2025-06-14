package stages;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;

using funkin.backend.utils.ObjectUtils;

function main():Void
{
	Paths.sound('Lights_Turn_On'); // preload
}

function onCreate():Void
{
	setDefaultGF('gf-christmas');

	var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	addHxObject(bg);

	addHxObject(new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2));
	addHxObject(new BGSprite('christmas/evilSnow', -200, 700));

	// Winter Horrorland cutscene
	setupCallback();
}

function setupCallback():Void
{
	if ((isStoryMode && !seenCutscene) && songName == 'winter-horrorland')
		startCallback = winterHorrorlandCutscene;
}

var blackScreen:FlxSprite;

function winterHorrorlandCutscene():Void
{
	addHxObject(blackScreen = new FlxSprite().makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK));
	blackScreen.scrollFactor.set();

	camHUD.visible = false;
	inCutscene = true;

	FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
		ease: FlxEase.linear,
		onComplete: function(twn:FlxTween)
		{
			remove(blackScreen);
		}
	});
	FlxG.sound.play(Paths.sound('Lights_Turn_On'));
	FlxG.camera.zoom = 1.5;
	FlxG.camera.focusOn(FlxPoint.weak(400, -2050));

	new FlxTimer().start(0.8, (tmr:FlxTimer) ->
	{
		remove(blackScreen);
		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
			ease: FlxEase.quadInOut,
			onComplete: (twn:FlxTween) ->
			{
				camHUD.visible = true;
				startCountdown();
			}
		});
	});
}
