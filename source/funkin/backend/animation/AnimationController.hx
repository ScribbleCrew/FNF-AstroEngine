package funkin.backend.animation;

import flixel.animation.FlxAnimationController;

class AnimationController extends FlxAnimationController
{
	public var followGlobalSpeed:Bool = true;

	public override function update(elapsed:Float):Void
	{
		if (_curAnim != null)
			_curAnim.update(elapsed * (timeScale * (followGlobalSpeed ? FlxG.animationTimeScale : 0)));
		else if (_prerotated != null)
			_prerotated.angle = _sprite.angle;
	}
}
