package funkin.game.states;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import openfl.display.ShaderParameter;
import flixel.addons.display.FlxRuntimeShader;
@:nullSafety
class InDevWarningState extends MusicBeatState
{
	inline static function leave():Void
	{
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new TitleState());
	}

	//
	var transitioning:Bool = false;

	var warningWhat:Alphabet;
	var warningText:FunkinText;
	var warningBtns:FunkinText;
	var scripts:ScriptPack;

	#if SHADERS_ALLOWED
	var background:FlxSprite;
	var void:Null<CirclePulseShader>;
	#end

	public function new():Void
	{
		// initialize everything before calling super
		#if SHADERS_ALLOWED
		if (ClientPrefs.data.shaders)
			void = new CirclePulseShader();
		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		#end

		scripts = new ScriptPack();
		warningWhat = new Alphabet(0, 0, '', true);
		warningText = new FunkinText(16, 0, FlxG.width - 32, "", 32);
		warningBtns = new FunkinText(18, 0, FlxG.width - 32, "", 24);

		super();
	}

	static var developmentText(get, never):String;

	@:nullSafety(Off) @:noCompletion static inline function get_developmentText():String
		return Paths.getTextFromFile("data/developmentWarning.txt", true);

	@:dox(hide) override public function create():Void
	{
		scripts.setParent(this);

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
				void.circleColor.value = [0.8, 0.6, 1.0]; // light purple
				void.backgroundColor.value = [0.0, 0.0, 0.0]; // black
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

		if (void != null)
			void.update(elapsed);

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
						FlxTween.num(i.alpha, 0, .5, null, i.set_alpha);
					FlxTween.num(warningBtns.y, 1000, 1., {ease: FlxEase.cubeInOut, startDelay: .33}, warningBtns.set_y);
				}

				// FlxTween.tween(warningBtns, {y: 1000}, 0.5, {ease: FlxEase.cubeInOut});
				#if SHADERS_ALLOWED
				if (background != null)
					background = FlxDestroyUtil.destroy(background);
				#end
				FlxG.camera.flash(FlxColor.WHITE, 1., () -> FlxG.camera.fade(FlxColor.BLACK, 2.33, false, leave));
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

class CirclePulseShader extends flixel.addons.display.FlxRuntimeShader
{
	/*
		@:glFragmentSource('
		   #pragma header

		uniform float time;
		uniform vec3 circleColor;
		uniform vec3 backgroundColor;
		uniform float frequency;
		uniform float speed;
		uniform bool showLines;

		const float PI = 3.14159265;

		float tex(vec2 pos){
		float upper = length(vec2(cos(PI/3.), sin(PI/3.)) * length(pos) - pos);
		return min(pow(upper, .11), pow(1. - length(pos), .2));
		}

		void main() {
		// Normalized position (-1 to 1), aspect-corrected
		vec2 uv = openfl_TextureCoordv * 2.0 - 1.0;
		uv.y *= openfl_TextureSize.y / openfl_TextureSize.x;

		vec4 baseColor = vec4(backgroundColor, 1.0);
		gl_FragColor = baseColor;

		vec2 circleDistor = uv;
		circleDistor /= (sqrt(5.0) - length(circleDistor));
		float modab = 1.0;
		float off = mod(time * speed, 1.0) * modab;
		circleDistor = normalize(circleDistor) * mod(length(circleDistor) - off, modab);
		float ang = asin(circleDistor.y / length(circleDistor));
		if(circleDistor.x < 0.0){
			ang = PI - ang;
		}
		ang = mod(ang, PI / frequency);
		circleDistor = vec2(cos(ang), sin(ang)) * length(circleDistor);
		vec4 col = mix(vec4(circleColor, 1.0), baseColor, tex(circleDistor));

		if(showLines){
			gl_FragColor = col;
		} else {
			gl_FragColor = baseColor;
		}
		}
		') */
	public var time:ShaderParameter<Float>;
	public var circleColor:ShaderParameter<Float>;
	public var backgroundColor:ShaderParameter<Float>;
	public var frequency:ShaderParameter<Float>;
	public var speed:ShaderParameter<Float>;
	public var showLines:ShaderParameter<Bool>;

	public function new()
	{
		final frag = Paths.shaderFragment('warningPulse');
		super(FileSystem.exists(frag) ? File.getContent(frag) : null);

		time = getFloatParam("time", [0.0]);
		circleColor = getFloatParam("circleColor", [1.0, 1.0, 1.0]);
		backgroundColor = getFloatParam("backgroundColor", [0.0, 0.0, 0.0]);
		frequency = getFloatParam("frequency", [1.0]);
		speed = getFloatParam("speed", [.5]);
		showLines = getBoolParam("showLines", [true]);
	}

	public function update(elapsed:Float):Void
	{
		if (time != null)
			time.value[0] += elapsed;
	}

	function getFloatParam(id:String, defaultValue:Array<Dynamic>):ShaderParameter<Float>
		return cast getParam(id, defaultValue);

	function getBoolParam(id:String, defaultValue:Array<Dynamic>):ShaderParameter<Bool>
		return cast getParam(id, defaultValue);

	function getParam(id:String, defaultValue:Array<Dynamic>):Dynamic
	{
		final field = Reflect.field(this.data, id);
		if (field != null)
			field.value = defaultValue;
		else
			trace('Missing shader param: $id');
		return field;
	}
}
