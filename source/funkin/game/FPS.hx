package funkin.game;

/**
 * The FPS class provides an easy-to-use monitor to display
 * the current frame rate of an OpenFL project.
 * Highly modified for Astro Engine.
 */
@:access(openfl.display.DisplayObject)
@:keep class FPS extends openfl.text.TextField
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 *	The current frame rate (expressed using frames-per-second)
	 */
	public var currentFPS(default, null):Int;

	/**
	 * I genuinely have no idea what this does, all i know is that 
	 * it's used to calculate the framerate.
	 */
	private var times:Array<Float>;

	/**
	 * The current memory usage (WARNING: this is NOT your total program memory usage, 
	 * rather it shows the garbage collector memory)
	 */
	@:isVar
	public var memoryMegas(get, never):Float;
	@:dox(hide) @:noCompletion private inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

	/**
	 * The translucent background.
	 */
	public var bgSprite:openfl.display.Sprite;

	/**
	 * Background offset.
	 */
	public var bgOffset:FlxPoint = FlxPoint.get();

	/**
	 * Pushes a string to the text variable (FPS Stuff)
	 */
	public inline function addLine(str:String = ""):String
		return text += '${text != '' ? '\n' : ''}$str';

	/**
	 * Clear's the whole framerate field (NOTICE: allowed to be used in HScript).
	 */
	public inline function clear():String
		return text = '';

	/**
	 * Changes `updateFPS` function to the default value.
	 */
	public inline function reset():Void->Void
		return updateFPS = _default;

	/**
	* Basic set position function, does it even work?
	*/
	public inline function setPosition(?X:Null<Float>, ?Y:Null<Float>):Float
		return { this.x = X; this.y = Y; } 

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		/**
		* u dumb?
		*/
		super();

		/**
		 * Setting the given positions.
		 */
		setPosition(x,y);

		/**
		 * Default stuff
		 */
		times = [];
		currentFPS = 0;
		updateFPS = _default;

		/**
		 * Setting up the textfield.
		 */
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 14, color, false);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		/**
		 * Creating the background sprite.
		 */
		bgSprite = new openfl.display.Sprite();
		bgSprite.graphics.beginFill(0xFF000000);
		bgSprite.graphics.drawRect(0, 0, 1, 1);
		bgSprite.graphics.endFill();
		bgSprite.alpha = _bgAlpha;

		/**
		 * Syncs with `showFPS` @ `ClientPrefs.data`.
		 */
		visible = active = bgSprite.visible = ClientPrefs.data.showFPS;

		/**
		 * Resets the fps field to its default value.
		 */
		FlxG.signals.preStateSwitch.add(reset); // extra check.
	}

	/**
	 * Prevents the overlay from updating every frame, why would you need to anyways. - @crowplexus
	 */
	var deltaTimeout:Float = 0.0;

	/**
	 * Updates the fps field.
	 */
	public var updateFPS:Void->Void;

	/**
	 * The `__enterFrame` fps update.
	 */
	@:dox(hide) @:noCompletion private override function __enterFrame(deltaTime:Float):Void
	{
		/**
		 * Times push thingy???
		 */
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		/**
		 * Crowplexus delta timeout.
		 */
		if (deltaTimeout < 50)
		{
			deltaTimeout += deltaTime;
			return;
		}

		/**
		 * Update `currentFPS` with recalculated fps.
		 */
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateFPS();
		deltaTimeout = 0.0;

		/**
		 * Set the `bgSprite`'s scale.
		 */
		bgSprite.scaleX = this.width + bgOffset.x * 2 - 10;
		bgSprite.scaleY = this.height + bgOffset.y * 2 + 3;
	}

	/**
	 * Default framerate update function
	 */
	@:dox(hide) @:noCompletion private dynamic function _default():Void
	{
		/**
		 * Clear, ofc...
		 */
		clear();

		/**
		 * My stupid stuff...
		 */
		addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.goober ? "owo's per second" : #end 'FPS'}: $currentFPS');
		addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.goober ? "proot mem usage" : #end 'Memory'}: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}');
		#if GIT_ALLOWED addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.goober ? "orbl pick one pls 🙏" : #end "Commit"}: ${GitMacro.commitNumber} [${GitMacro.commitHash}] ${GitMacro.branch}'); #end

		/**
		 * Low FPS Check.
		 */
		(currentFPS < FlxG.drawFramerate * 0.5) ? textColor = 0xFFFF0000 : textColor = 0xFFFFFFFF;
	}

	/**
	 * Framerate background alpha float.
	 */
	@:noCompletion private static inline final _bgAlpha:Float = (1 / 3);

	/**
	 * Modified `set_alpha` to take the `bgSprite`'s alpha in account
	 * and change it accordingly.
	 */
	@:dox(hide) @:noCompletion override function set_alpha(value:Float):Float
	{
		if (value < _bgAlpha)
			bgSprite.alpha = value;
		return super.alpha = value;
	}

	/**
	 * Modified `set_visible` function to change the visibility of `bgSprite`.
	 */
	@:dox(hide) @:noCompletion override function set_visible(value:Bool):Bool
		return bgSprite.visible = super.visible = value;
}
