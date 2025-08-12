package scripts.songs.tutorial;

var cameraTwn:FlxTween;

// function _moveCamera(isDad:Bool):Void
function onMoveCamera(focus:String):Void
{
	final duh:Float = (focus != 'dad' ? 1 : 1.3);
	if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != duh)
	{
		cameraTwn = FlxTween.tween(FlxG.camera, {zoom: duh}, (Conductor.stepCrochet * 4 / 1000), {
			ease: FlxEase.elasticInOut,
			onComplete: (twn:FlxTween) -> cameraTwn = null
		});
	}
}

function onDestroy():Void
{
	if (cameraTwn != null)
	{
		cameraTwn.cancel();
		cameraTwn = null;
	}
}
