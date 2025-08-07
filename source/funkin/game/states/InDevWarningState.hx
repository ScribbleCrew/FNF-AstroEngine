#if INDEV_SCREEN
package funkin.game.states;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.transition.FlxTransitionableState;

@:nullSafety
class InDevWarningState extends MusicBeatState
{
	/*inline*/
	static dynamic function leave():Void
	{
		#if !mobile
		if (Main.framerateCounter != null)
			Main.framerateCounter.visible = ClientPrefs.data.showFPS;
		#end
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new TitleState());
	}

	//
	var transitioning:Bool = false;

	var warningWhat:Alphabet;
	var warningText:FunkinText;
	var warningBtns:FunkinText;
	var engineLogo:FlxSprite;
	var scripts:ScriptPack;

	var subCam:Null<FlxCamera>;

	#if SHADERS_ALLOWED
	// this background is only used for shaders so there is no need to create it with shaders disabled.
	var background:Null<FlxSprite>;
	var void:Null<FlxRuntimeShader>;

	static var frag(get, never):String;

	@:dox(hide) @:noCompletion static inline function get_frag():Null<String>
		return Paths.shaderFragment('WarningPulse');

	//
	// HELPERS
	//
	static function intToVec3(color:Int):Array<Float>
		return [
			((color >> 16) & 0xFF) / 255.0,
			((color >> 8) & 0xFF) / 255.0,
			(color & 0xFF) / 255.0
		];
	#end

	//	var subCameraDuh:FlxCamera;

	public function new():Void
	{
		// initialize everything before calling super
		#if SHADERS_ALLOWED
		if (ClientPrefs.data.shaders)
		{
			void =
				{
					if (!FileSystem.exists(frag))
						null;
					else
					{
						final _:FlxRuntimeShader = new FlxRuntimeShader(File.getContent(frag));
						_.setFloat("iTime", 0);
						_.setFloat("frequency", 1.0);
						_.setFloatArray("uCircColor", intToVec3(0xFFA4C1FF));

						_;
					}
				};
			background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		}
		#end

		scripts = new ScriptPack();
		warningWhat = new Alphabet(0, 0, '', true);
		warningText = new FunkinText(16, 0, FlxG.width - 32, "", 32);
		warningBtns = new FunkinText(18, 0, FlxG.width - 32, "", 24);
		engineLogo = new FlxSprite();

		super();

		// fuck off, im stupid ik :(
		subCam = setupCamera();
	}

	static var developmentText(get, never):String;

	@:dox(hide) @:noCompletion static inline function get_developmentText():String
		return Paths.getTextFromFile("data/developmentWarning.txt", true) ?? '';

	@:dox(hide) override public function create():Void
	{
		// checks
		// im lazy so yeahh don't judge me
		if (developmentText == null)
		{
			FlxG.switchState(new TitleState());
			return;
		}

		scripts.setParent(this);
		#if !mobile
		if (Main.framerateCounter != null)
			Main.framerateCounter.visible = false;
		#end
		#if HSCRIPT_ALLOWED
		final base:String = Paths.script();
		for (i in 1...3)
		{
			final e:String = '${base}test$i.hx';
			if (FileSystem.exists(e))
				scripts.add(new HScript(null, e).run());
		}
		#end

		Windows.title = '%{GAME_TITLE} - Development Warning';
		FlxG.mouse.visible = false;

		function duh(path:String):String
			return path.replace('\\n', '').replace('\\l', '\n').substitute([Main.releaseCycle]);

		// make into a json?
		final markdwn:Array<FlxTextFormatMarkerPair> = [
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF5252), "<important>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF0A4FF), "<sillyFormat>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF8E4C), "<reinworld>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF7DFF7D), "<luckyCharms>")
		];

		final wahh:Array<String> = [
			for (line in developmentText.split("__LUNARREF_HEADER__F"))
				line.trim()
		];

		scripts.call('testing', [["arg1", "arg3"], "huh"]); // dude i fucking hate my life

		super.create();

		#if SHADERS_ALLOWED
		@:nullSafety(Off) {
			if (void != null && background != null)
			{
				background.shader = void;
				background.screenCenter();
				add(background);
			}
		}
		#end

		// Make texts
		warningWhat.screenCenter(X);
		add(warningWhat);

		warningText.alignment = CENTER;
		add(warningText);

		warningBtns.alignment = CENTER;
		add(warningBtns);

		// make engine logo, currently using a placeholder.
		engineLogo.loadGraphic(Paths.image('credits/orbl'));
		engineLogo.scale.set(1.3, 1.3);
		engineLogo.screenCenter();
		engineLogo.alpha = 0;
		add(engineLogo);

		// Apply text and markup stuff.
		warningWhat.text = wahh[0];
		warningText.applyMarkup(duh(wahh[1]), markdwn);
		warningBtns.applyMarkup(duh(wahh[2]), markdwn);

		// Positioning.
		warningText.y = warningWhat.y + warningWhat.height + 10;
		warningBtns.y = warningText.y + warningText.height + 10;

		//	for (i in [warningWhat, warningText, warningBtns])
		//		i.y += Std.int((FlxG.height - ((warningBtns.y + warningBtns.height) - warningWhat.y)) / 2) - warningWhat.y;

		final vOffset:Float = Std.int((FlxG.height - ((warningBtns.y + warningBtns.height) - warningWhat.y)) / 2) - warningWhat.y;
		warningWhat.y += vOffset;
		warningText.y += vOffset;
		warningBtns.y += vOffset;

		warningWhat.screenCenter(X);
	}

	@:dox(hide) override function destroy():Void
	{
		scripts.destroy();
		super.destroy();
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// if (void != null)
		#if SHADERS_ALLOWED
		if (ClientPrefs.data.shaders)
			if (void != null)
				@:nullSafety(Off) Reflect.field(void.data, 'iTime').value[0] += elapsed; // easier than using `getFloat` and `setFloat`
		#end

		if (controls.ACCEPT && transitioning)
		{
			FlxG.camera.stopFX();
			FlxG.camera.visible = false;
			leave();
		}

		if (!transitioning)
		{
			if (controls.ACCEPT)
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);

				@:privateAccess {
					for (i in [warningWhat, warningText])
						FlxTween.num(i.alpha, 0, .5, {startDelay: .2}, i.set_alpha);
					FlxTween.num(warningBtns.y, 1000, 1., {ease: FlxEase.cubeInOut, startDelay: .33}, warningBtns.set_y);
					if (subCam != null)
						FlxTween.num(subCam.zoom, 2., 15., {ease: FlxEase.expoOut}, FlxG.camera.set_zoom);

					#if SHADERS_ALLOWED
					if (ClientPrefs.data.shaders && void != null)
					{
						@:nullSafety(Off) {
							final initialColor:Array<Float> = Reflect.field(void.data, "uCircColor").value;
							final targetColor:Array<Float> = intToVec3(0xFFFFFDA4);
							final color:{r:Float, g:Float, b:Float} = {r: initialColor[0], g: initialColor[1], b: initialColor[2]};
							FlxTween.tween(color, {r: targetColor[0], g: targetColor[1], b: targetColor[2]}, 2,
								{onUpdate: (_) -> void.setFloatArray("uCircColor", [color.r, color.g, color.b])});
						}
					}
					#end

					// looks better i guess :p
					FlxTween.num(engineLogo.alpha, 1, {ease: FlxEase.cubeInOut, startDelay: .33}, engineLogo.set_alpha);
					// FlxTween.num(engineLogo.y, (FlxG.height - engineLogo.height) / 2, {ease: FlxEase.cubeInOut}, engineLogo.set_y);
				}

				// FlxTween.tween(warningBtns, {y: 1000}, 0.5, {ease: FlxEase.cubeInOut});
				// #if SHADERS_ALLOWED
				// if (background != null)
				// background = FlxDestroyUtil.destroy(background);
				// #end
				new FlxTimer().start(1.5, (_) -> FlxG.camera.fade(FlxColor.BLACK, 2.33, false, () -> new FlxTimer().start(1, _ -> leave())));
				// FlxG.camera.flash(FlxColor.WHITE, 1., () -> FlxG.camera.fade(FlxColor.BLACK, 2.33, false, leave));
				FlxFlicker.flicker(warningBtns, 1, .1, false, true);
			}
			else if (controls.BACK)
				CoolUtil.browserLoad(EngineData.REPOSITORY);
		}
		else
		{
			if (controls.ACCEPT)
			{
				FlxG.camera.stopFX();
				FlxG.camera.visible = false;
			}
		}
	}
}
#end
