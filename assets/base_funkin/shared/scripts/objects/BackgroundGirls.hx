package objects;

import funkin.backend.CoolUtil;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundGirls extends BGSprite
{
	public var isPissed:Bool = true;

	public function new(x:Float, y:Float) : Void
	{
		super(x, y, null);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgFreaks');
		antialiasing = false;
		__remapAnimations();

		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		updateHitbox();
		animation.play('danceLeft');
	}

	var __danceDir:Bool = false;

	public function __remapAnimations():Void
	{
		isPissed = !isPissed;
		animation.addByIndices('danceLeft', isPissed ? 'BG fangirls dissuaded' : 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', isPissed ? 'BG fangirls dissuaded' : 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);

		dance();
	}

	public function dance():Void
	{
		__danceDir = !__danceDir;
		animation.play(__danceDir ? 'danceRight' : 'danceLeft', true);
	}
}
