package funkin.game;

/**
 * Custom FPS class which provides a customizable, displays the fps, memory, and git information.
 * I don't actually what made me rewrite this, but it's soo so cool!
 *
 * Takes customizability in account allowing this call to be used in HScript & Lua.
 *
 * To modders,
 * If you want to enable/disable modding, change `CUSTOM_FPS_ALLOWED` @ Project.xml
 */
@:access(openfl.display.DisplayObject)
class FPS extends openfl.text.TextField
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, 
	 * keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Applications current framerate 
	 * (expressed using frames-per-second).
	 */
	public var currentFPS(default, null):Int;

	/**
	 * I genuinely have no idea what this does, all i know is that 
	 * it's used to calculate the framerate.
	 */
	var _times:Array<Float>;

	/**
	 * The current memory usage (WARNING: this is NOT your total program memory usage, 
	 * rather it shows the garbage collector memory)
	 *
	 * @returns The memory tracked by the garbage collector (expressed as megabytes).
	 */
	@:isVar
	public var memoryMegabytes(get, never):Float;
	@:dox(hide) inline function get_memoryMegabytes():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

	/**
	 * The translucent background.
	 */
	public var bgSprite:openfl.display.Sprite;

	/**
	 * Background offset.
	 */
	public var bgOffset:FlxPoint = FlxPoint.get(25,5);

	/**
	 * Pushes a string to the text variable (FPS Stuff)
	 */
	public inline function addLine(str:String = ""):String
		return text += '${text != '' ? '\n' : ''}$str';

	/**
	 * Clear's the whole framerate field 
	 * (NOTICE: allowed to be used in HScript).
	 */
	public inline function clear():String
		return text = '';

	/**
	 * The default position of the framerate counter.
	 */
	@:dox(hide) var __defaultPosition(default, null):FlxPoint;

	/**
	 * Changes `updateFPS` function to the default value
	 * (NOTICE: also changes the position).
	 */
	public inline function reset(changePos:Bool = true):Void->Void
	{
		if (changePos)
		{
			/** 
			 * Reset the text position.
			 */
			__defaultPosition != null ? setPosition(__defaultPosition.x, __defaultPosition.y) : setPosition(10, 3);
	
			/** 
			* reset `bgSprite` position. 
			*/
			bgSprite.scaleX = this.width + 25 * 2 - 10;
			bgSprite.scaleY = this.height + 5 * 2 + 3;
		}

		return updateFPS = __defaultOptions;
	}

	/**
	 * Basic set position function, 
	 * does it even work?
	 */
	public inline function setPosition(x = 0.0, y = 0.0):Void
	{
		__defaultPosition = new FlxPoint(x, y);
		this.x = x;
		this.y = y;
	}

	/**
	* Checks low frames.	
	*/
	public inline function lowFramesCheck():Bool return (currentFPS < FlxG.drawFramerate * 0.5);

	public function new(x:Float = 10, y:Float = 3, color:Int = 0x000000, visible:Bool = true)
	{
		/**
		 * oof
		 */
		super();

		/**
		 * Setting the given positions.
		 */
		setPosition(x, y);

		/**
		* Setting the visibility.
		*/
		super.visible = visible;

		/**
		 * Default stuff
		 */
		_times = [];
		currentFPS = 0;
		updateFPS = __defaultOptions;

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
		FlxG.signals.preStateSwitch.add(() -> this.resetOnStateChange ? reset() : null); // extra check.
	}

	/**
	* Should the fps field reset to it's default value.
	*/
	public var resetOnStateChange:Bool = true;

	/**
	 * Prevents the overlay from updating every frame, 
	 * why would you need to anyways. - @crowplexus
	 */
	var deltaTimeout:Float = 0.0;

	/**
	 * Updates the FPS field.
	 */
	#if CUSTOM_FPS_ALLOWED public #else private #end var updateFPS:Void->Void;

	/**
	 * The `__enterFrame` fps update.
	 */
	@:dox(hide) @:noCompletion override function __enterFrame(deltaTime:Float):Void
	{		
		final elapsed:Float = deltaTime / 1000;

		/**
		 * _times push thingy???
		 */
		final now:Float = haxe.Timer.stamp() * 1000;
		_times.push(now);
		while (_times[0] < now - 1000)
			_times.shift();

		/**
		 * Stops `updateFPS` from being ran every frame.
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
		currentFPS = _times.length < FlxG.updateFramerate ? _times.length : FlxG.updateFramerate;
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
	@:dox(hide) @:noCompletion dynamic function __defaultOptions():Void
	{
		/**
		 * Clear, ofc...
		 */
		clear();

		/**
		 * FPS Text Field
		 */
		addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.goober ? "owo's per second" : #end 'FPS'}: $currentFPS');
		
		/**
		 * Memory Text Field
		 */
		addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.goober ? "proot mem usage" : #end 'Memory'}: ${flixel.util.FlxStringUtil.formatBytes(memoryMegabytes)}');
		
		/**
		 * Commit Data (Git)
		 */
		#if GIT_ALLOWED addLine('${#if ASTRO_WATERMARKS ClientPrefs.data.goober ? "orbl pick one pls 🙏" : #end "Commit"}: ${GitMacro.commitNumber} [${GitMacro.commitHash}] ${GitMacro.branch}'); #end

		/**
		 * Low FPS Check.
		 */
		lowFramesCheck() ? textColor = 0xFFFF0000 : textColor = 0xFFFFFFFF;
	}

	/**
	 * Framerate background alpha float.
	 */
	@:dox(hide) @:noCompletion inline static final _bgAlpha:Float = (1 / 3);

	/**
	 * Modified `set_alpha` to take the `bgSprite`'s alpha 
	 * in account and change it accordingly.
	 */
	@:dox(hide) @:noCompletion override function set_alpha(value:Float):Float
	{
		if (value < _bgAlpha) bgSprite.alpha = value;
		return super.alpha = value;
	}

	/**
	 * Modified `set_visible` function to change the 
	 * visibility of `bgSprite`.
	 */
	@:dox(hide) @:noCompletion override function set_visible(value:Bool):Bool
		return bgSprite.visible = super.visible = value;

	/**
	 * Smol `create()` function to reduce lines of da code
	 * this looks way better than the other way. OKAY!!! (pls don't bully me...)
	 */
	public inline static function make():FPS
		return new FPS(10, 3, 0xFFFFFF, false);
}
