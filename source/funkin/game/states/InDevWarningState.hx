package funkin.game.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class InDevWarningState extends MusicBeatState
{
	static inline final RED:Int = 0xFFFF5252;

	static final leave:() -> Void = () ->
	{
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new TitleState());
	}

	var transitioning:Bool = false;

	var warningWhat:Alphabet;
	var warningText:FunkinText;
	var scripts:ScriptPack;

	override public function create():Void
	{
		scripts = new ScriptPack();

		final base = Paths.script();
		for (i in 1...3)
		{
			final e:String= '${base}test$i.hx';
			if (FileSystem.exists(e))
				scripts.add(new HScript(null, e).run());
		}

		WindowUtil.title = '%{GAME_TITLE} - Development Warning';
		FlxG.mouse.visible = false;

		super.create();

		warningWhat = new Alphabet(0, 0, "!!! Warning !!!", true);
		warningWhat.color = RED;
		warningWhat.screenCenter(X);
		add(warningWhat);

		warningText = new FunkinText(16, warningWhat.y + warningWhat.height + 10, FlxG.width - 32, "", 32);
		warningText.alignment = CENTER;
		add(warningText);

		warningText.applyMarkup(Paths.getTextFromFile("data/developmentWarning.txt", true) // the 2nd true forces it to check embedded files
			.replace('\\n', '')
			.replace('\\l', '\n')
			.substitute([Main.releaseCycle]), [
				new FlxTextFormatMarkerPair(new FlxTextFormat(RED), "<important>"),
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF0A4FF), "<sillyFormat>"),
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF8E4C), "<reinworld>"),
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF7DFF7D), "<luckyCharms>")
			]);

		final v:Int = Std.int((FlxG.height - (warningText.y + warningText.height)) / 2);
		warningText.y += v;
		warningWhat.y += v;

		scripts.call('testing', ["arg1", "arg3"]); // dude i fucking hate my life
	}

	override function update(elapsed:Float):Void
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
				FlxG.camera.flash(FlxColor.WHITE, 1.0, () -> FlxG.camera.fade(FlxColor.BLACK, 2.66, false, leave));
			}
			else if (controls.BACK)
				CoolUtil.browserLoad(EngineData.REPOSITORY);
		}
	}
}
