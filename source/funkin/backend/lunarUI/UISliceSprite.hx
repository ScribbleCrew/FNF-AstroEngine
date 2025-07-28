package funkin.backend.lunarUI;

import flixel.FlxG;
import flixel.util.FlxAxes;
import funkin.backend.utils.Paths;
import flixel.graphics.frames.FlxFrame;

/**
 * Greatly inspired by cnes slice sprite handler.
 */
class UISliceSprite extends UIObject
{
	public var bWidth:Int = 120;
	public var bHeight:Int = 20;

	public var framesOffset:Int = 0;

	public function new(x:Float, y:Float, w:Int, h:Int, path:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas(path);
		this.resize(w, h);
	}

	public function sCenter(?axes:FlxAxes = XY):UISliceSprite
	{
		if (axes.x)
			x = (FlxG.width - bWidth) / 2;

		if (axes.y)
			y = (FlxG.height - bHeight) / 2;

		return this;
	}

	public function resize(w:Int, h:Int):UISliceSprite
	{
		bWidth = w;
		bHeight = h;

		return this;
	}

	@:noCompletion public var drawTop:Bool = true;
	@:noCompletion public var drawMiddle:Bool = true;
	@:noCompletion public var drawBottom:Bool = true;

	public override function draw() : Void
	{
		@:privateAccess {
			final x:Float = this.x, y = this.y;

			if (visible && !(bWidth == 0 || bHeight == 0))
			{
				var topleft:FlxFrame = frames.frames[framesOffset];
				var top:FlxFrame = frames.frames[framesOffset + 1];
				var topright:FlxFrame = frames.frames[framesOffset + 2];
				var middleleft:FlxFrame = frames.frames[framesOffset + 3];
				var middle:FlxFrame = frames.frames[framesOffset + 4];
				var middleright:FlxFrame = frames.frames[framesOffset + 5];
				var bottomleft:FlxFrame = frames.frames[framesOffset + 6];
				var bottom:FlxFrame = frames.frames[framesOffset + 7];
				var bottomright:FlxFrame = frames.frames[framesOffset + 8];

				// TOP
				if (drawTop)
				{
					// TOP LEFT
					frame = topleft;
					setPosition(x, y);
					__setSize(topleft.frame.width * Math.min(bWidth / (topleft.frame.width * 2), 1),
						topleft.frame.height * Math.min(bHeight / (topleft.frame.height * 2), 1));
					super.draw();

					// TOP
					if (bWidth > topleft.frame.width + topright.frame.width)
					{
						frame = top;
						setPosition(x + topleft.frame.width, y);
						__setSize(bWidth - topleft.frame.width - topright.frame.width, top.frame.height * Math.min(bHeight / (top.frame.height * 2), 1));
						super.draw();
					}

					// TOP RIGHT
					setPosition(x + bWidth - (topright.frame.width * Math.min(bWidth / (topright.frame.width * 2), 1)), y);
					frame = topright;
					__setSize(topright.frame.width * Math.min(bWidth / (topright.frame.width * 2), 1),
						topright.frame.height * Math.min(bHeight / (topright.frame.height * 2), 1));
					super.draw();
				}

				// MIDDLE
				if (drawMiddle && bHeight > top.frame.height + bottom.frame.height)
				{
					var middleHeight:Float = bHeight
						- (topleft.frame.height * Math.min(bHeight / (topleft.frame.height * 2), 1))
						- bottomleft.frame.height * Math.min(bHeight / (bottomleft.frame.height * 2), 1);

					// MIDDLE LEFT
					frame = middleleft;
					setPosition(x, y + top.frame.height);
					__setSize(middleleft.frame.width * Math.min(bWidth / (middleleft.frame.width * 2), 1), middleHeight);
					super.draw();

					if (bWidth > (middleleft.frame.width * Math.min(bWidth / (middleleft.frame.width * 2), 1)) + middleright.frame.width)
					{
						// MIDDLE
						frame = middle;
						setPosition(x + topleft.frame.width, y + top.frame.height);
						__setSize(bWidth - middleleft.frame.width - middleright.frame.width, middleHeight);
						super.draw();
					}

					// MIDDLE RIGHT
					frame = middleright;
					setPosition(x + bWidth - (topright.frame.width * Math.min(bWidth / (topright.frame.width * 2), 1)), y + top.frame.height);
					__setSize(middleright.frame.width * Math.min(bWidth / (middleright.frame.width * 2), 1), middleHeight);
					super.draw();
				}

				// BOTTOM
				if (drawBottom)
				{
					// BOTTOM LEFT
					frame = bottomleft;
					setPosition(x, y + bHeight - (bottomleft.frame.height * Math.min(bHeight / (bottomleft.frame.height * 2), 1)));
					__setSize(bottomleft.frame.width * Math.min(bWidth / (bottomleft.frame.width * 2), 1),
						bottomleft.frame.height * Math.min(bHeight / (bottomleft.frame.height * 2), 1));
					super.draw();

					if (bWidth > bottomleft.frame.width + bottomright.frame.width)
					{
						// BOTTOM
						frame = bottom;
						setPosition(x + bottomleft.frame.width, y + bHeight - (bottom.frame.height * Math.min(bHeight / (bottom.frame.height * 2), 1)));
						__setSize(bWidth - bottomleft.frame.width - bottomright.frame.width,
							bottom.frame.height * Math.min(bHeight / (bottom.frame.height * 2), 1));
						super.draw();
					}

					// BOTTOM RIGHT
					frame = bottomright;
					setPosition(x
						+ bWidth
						- (bottomright.frame.width * Math.min(bWidth / (bottomright.frame.width * 2), 1)),
						y
						+ bHeight
						- (bottomright.frame.height * Math.min(bHeight / (bottomright.frame.height * 2), 1)));
					__setSize(bottomright.frame.width * Math.min(bWidth / (bottomright.frame.width * 2), 1),
						bottomright.frame.height * Math.min(bHeight / (bottomright.frame.height * 2), 1));
					super.draw();
				}
			}

			setPosition(x, y);
			super.__drawMembers();
		}
	}

	@:noCompletion function __setSize(w:Float, h:Float):Void
	{
		final xScale:Float = w / frameWidth, yScale = h / frameHeight;
		scale.set(xScale, yScale);

		if (w <= 0)
			scale.x = yScale;
		else if (h <= 0)
			scale.y = xScale;

		updateHitbox();
	}
}
