package funkin.game.states;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;

@:nullSafety
class InDevWarningState extends MusicBeatState
{
	static inline final customRedColor:Int = 0xFFFF5252;

	static final leave:() -> Void = () ->
	{
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new TitleState());
	}

	var transitioning:Bool = false;

	var warningWhat:Alphabet;
	var warningText:FunkinText;
	var warningBtns:FunkinText;
	var scripts:ScriptPack;

	public function new():Void
	{
		// initialize everything before calling super
		scripts = new ScriptPack();
		warningWhat = new Alphabet(0, 0, '', true);
		warningText = new FunkinText(16, 0, FlxG.width - 32, "", 32);
		warningBtns = new FunkinText(18, 0, FlxG.width - 32, "", 24);

		super();
	}

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
			new FlxTextFormatMarkerPair(new FlxTextFormat(customRedColor), "<important>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF0A4FF), "<sillyFormat>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF8E4C), "<reinworld>"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF7DFF7D), "<luckyCharms>")
		];
		@:nullSafety(Off) final ehh:String = Paths.getTextFromFile("data/developmentWarning.txt", true);
		if (ehh == null)
		{
			FlxG.switchState(new TitleState());
			return;
		}
		final wahh:Array<String> = [
			for (line in ehh.split("__LUNARREF_HEADER__F"))
				line.trim()
		];

		scripts.call('testing', [["arg1", "arg3"], "huh"]); // dude i fucking hate my life

		super.create();

		// Make texts
		warningWhat.color = customRedColor;
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
				FlxG.camera.flash(FlxColor.WHITE, 1.0, () -> FlxG.camera.fade(FlxColor.BLACK, 2.33, false, leave));
				FlxFlicker.flicker(warningBtns, 1, 0.1, false, true);
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
