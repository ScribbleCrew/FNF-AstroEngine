package funkin.backend.animation;

// add custom anim offsets
class AnimationController extends flixel.animation.FlxAnimationController
{
	/**
	* Follow the global speed.	
	*/
	public var followGlobalSpeed:Bool = true;
	
	@:dox(hide) override function update(elapsed:Float):Void
	{
		if (_curAnim != null)
			_curAnim.update(elapsed * (timeScale * (followGlobalSpeed ? FlxG.animationTimeScale : 0)));
		else if (_prerotated != null)
			_prerotated.angle = _sprite.angle;
	}
}
