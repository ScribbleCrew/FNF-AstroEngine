package funkin.backend.animation;

// add custom anim offsets
class AnimationController extends flixel.animation.FlxAnimationController
{
	public var followGlobalSpeed:Bool = true;

	@:dox(hide) override function update(v1:Float):Void
	{
		if (_curAnim != null)
			_curAnim.update(v1 * (timeScale * (followGlobalSpeed ? FlxG.animationTimeScale : 0)));
		else if (_prerotated != null)
			_prerotated.angle = _sprite.angle;
	}
}
