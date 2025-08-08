package funkin.backend.objects;

/**
 * This modified FlxCamera handles `followLerp` based on elapsed values, 
 * whiles also stopping the camera from snapping at higher framerates.
 */
class CustomCamera extends FlxCamera
{
	@:dox(hide) override inline function set_followLerp(value:Float)
		return followLerp = value;

	@:dox(hide) override public function update(elapsed:Float):Void
	{
		// delta
		if (target != null) _updateFollowDelta(elapsed);

		// update stuff
		updateScroll();
		updateFlash(elapsed);
		updateFade(elapsed);

		// fix filters
		flashSprite.filters = filtersEnabled ? filters : null;

		// fix flash sprite pos & update the shake.
		updateFlashSpritePosition();
		updateShake(elapsed);
	}

	@:dox(hide) public function _updateFollowDelta(?elapsed:Float = 0):Void
	{
		if (deadzone == null)
		{
			target.getMidpoint(_point);
			_point.addPoint(targetOffset);
			_scrollTarget.set(_point.x - width * 0.5, _point.y - height * 0.5);
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;

			if (style == SCREEN_BY_SCREEN)
			{
				if (targetX >= viewRight)
					_scrollTarget.x += viewWidth;
				else if (targetX + target.width < viewLeft)
					_scrollTarget.x -= viewWidth;

				if (targetY >= viewBottom)
					_scrollTarget.y += viewHeight;
				else if (targetY + target.height < viewTop)
					_scrollTarget.y -= viewHeight;

				bindScrollPos(_scrollTarget);
			}
			else
			{
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
					_scrollTarget.x = edge;

				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
					_scrollTarget.x = edge;

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
					_scrollTarget.y = edge;

				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
					_scrollTarget.y = edge;
			}

			if ((target is FlxSprite))
			{
				_lastTargetPosition ??= FlxPoint.get(target.x, target.y); // Creates this point.

				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}
		}

		final mult:Float = 1 - Math.exp(-elapsed * followLerp / (1 / 60));
		scroll.x += (_scrollTarget.x - scroll.x) * mult;
		scroll.y += (_scrollTarget.y - scroll.y) * mult;
	}
}
