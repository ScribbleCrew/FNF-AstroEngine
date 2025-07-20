package funkin.game.states;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.transition.FlxTransitionableState;

@:nullSafety
class InDevWarningState extends MusicBeatState
{
	/*inline*/ static dynamic function leave():Void
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

	#if SHADERS_ALLOWED
	var background:FlxSprite;
	var void:Null<FlxRuntimeShader>;

	static var frag(get, never):String;

	@:dox(hide) @:nullSafety(Off) @:noCompletion static inline function get_frag():String
		return Paths.shaderFragment('WarningPulse');

	function setShaderField(id:String, value:Dynamic):Void
	{
		if (void == null)
			return;
		final field:Dynamic = Reflect.field(void.data, id);
		if (field != null)
			field.value = value;
		else
			trace('Missing/Invalid shader param: $id');
	}
	#end

	//	var subCameraDuh:FlxCamera;

	public function new():Void
	{
		// initialize everything before calling super
		#if SHADERS_ALLOWED
		if (ClientPrefs.data.shaders)
			void = new FlxRuntimeShader(FileSystem.exists(frag) ? File.getContent(frag) : null);
		// final frag:String = Paths.shaderFragment('WarningPulse');
		// time = getFloatParam("time", [0.0]);
		// circleColor = getFloatParam("circleColor", [1.0, 1.0, 1.0]);
		// backgroundColor = getFloatParam("backgroundColor", [0.0, 0.0, 0.0]);
		// frequency = getFloatParam("frequency", [1.0]);
		// speed = getFloatParam("speed", [.5]);
		// showLines = getBoolParam("showLines", [true]);

		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		#end

		scripts = new ScriptPack();
		warningWhat = new Alphabet(0, 0, '', true);
		warningText = new FunkinText(16, 0, FlxG.width - 32, "", 32);
		warningBtns = new FunkinText(18, 0, FlxG.width - 32, "", 24);
		engineLogo = new FlxSprite();

		super();

		#if SHADERS_ALLOWED
		if (ClientPrefs.data.shaders)
		{
			setShaderField("iTime", [0]);
			setShaderField("frequency", [1.0]);
		}
		#end
	}

	static var developmentText(get, never):String;

	@:nullSafety(Off) @:noCompletion static inline function get_developmentText():String
		return Paths.getTextFromFile("data/developmentWarning.txt", true);

	@:dox(hide) override public function create():Void
	{
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

		WindowUtil.title = '%{GAME_TITLE} - Development Warning';
		FlxG.mouse.visible = false;

		function duh(path:String):String
			return path.replace('\\n', '').replace('\\l', '\n').substitute([Main.releaseCycle]);

		final markdwn:Array<FlxTextFormatMarkerPair> = [
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF5252), "<important>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF0A4FF), "<sillyFormat>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF8E4C), "<reinworld>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF7DFF7D), "<luckyCharms>")
		];
		// @:nullSafety(Off) final ehh:String = Paths.getTextFromFile("data/developmentWarning.txt", true);

		@:nullSafety(Off) // im lazy so yeahh don't judge me
		if (developmentText == null)
		{
			FlxG.switchState(new TitleState());
			return;
		}

		@:nullSafety(Off)
		final wahh:Array<String> = [
			for (line in developmentText.split("__LUNARREF_HEADER__F"))
				line.trim()
		];

		scripts.call('testing', [["arg1", "arg3"], "huh"]); // dude i fucking hate my life

		super.create();

		#if SHADERS_ALLOWED
		@:nullSafety(Off) {
			if (void != null)
			{
				setShaderField("circleColor", [0.1176, 0.0, 0.6314]); // Purple(ish) color
				background.shader = void;
			}
		}

		background.screenCenter();
		add(background);
		#end

		// Make texts
		warningWhat.screenCenter(X);
		add(warningWhat);

		warningText.alignment = CENTER;
		add(warningText);

		warningBtns.alignment = CENTER;
		add(warningBtns);

		engineLogo.loadGraphic(Paths.image('credits/orbl'));
		engineLogo.screenCenter(X);
		engineLogo.scale.set(1.3, 1.3);
		engineLogo.alpha = 0;
		engineLogo.screenCenter();
		add(engineLogo);

		// Appl text and markup stuff.
		warningWhat.text = wahh[0];
		warningText.applyMarkup(duh(wahh[1]), markdwn);
		warningBtns.applyMarkup(duh(wahh[2]), markdwn);

		// Positioning.
		warningText.y = warningWhat.y + warningWhat.height + 10;
		warningBtns.y = warningText.y + warningText.height + 10;

		//	for (i in [warningWhat, warningText, warningBtns])
		//		i.y += Std.int((FlxG.height - ((warningBtns.y + warningBtns.height) - warningWhat.y)) / 2) - warningWhat.y;

		final groupTop = warningWhat.y;
		final groupHeight = (warningBtns.y + warningBtns.height) - groupTop;
		final vOffset = Std.int((FlxG.height - groupHeight) / 2) - groupTop;

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
			@:nullSafety(Off) Reflect.field(void.data, 'iTime').value[0] += elapsed;
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
					FlxTween.num(FlxG.camera.zoom, 2., 15., {ease: FlxEase.expoOut}, FlxG.camera.set_zoom);
					// FlxTween.num(engineLogo.y, (FlxG.height - engineLogo.height) / 2, {ease: FlxEase.cubeInOut}, engineLogo.set_y);
					// looks better i guess :p
					FlxTween.num(engineLogo.alpha, 1, {ease: FlxEase.cubeInOut, startDelay: .33}, engineLogo.set_alpha);
				}

				// FlxTween.tween(warningBtns, {y: 1000}, 0.5, {ease: FlxEase.cubeInOut});
				#if SHADERS_ALLOWED
				// if (background != null)
				// background = FlxDestroyUtil.destroy(background);
				#end
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
