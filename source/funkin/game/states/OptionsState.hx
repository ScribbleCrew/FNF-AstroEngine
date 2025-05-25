package funkin.game.states;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.backend.system.MusicBeatState;

class OptionsState extends MusicBeatState
{
	public static var menuBG:FlxSprite;

	private final options:Array<String> = [
		'Note Colors',
		'Controls',
		'Graphics',
		'Gameplay',
		'Visuals and UI',
		'Adjust Delay and Combo'
	];
	private var grpOptions:FlxTypedGroup<funkin.game.objects.Alphabet>;

	private static var curSelected:Int = 0;

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Note Colors':
				openSubState(new NotesSubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Graphics':
				openSubState(new GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new VisualsUISubState());
			case 'Gameplay':
				openSubState(new GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new NoteOffsetState());
		}
	}

	var selectorLeft:funkin.game.objects.Alphabet;
	var selectorRight:funkin.game.objects.Alphabet;

	var OFFSETFUCKME:Int = 200;

	override function create()
	{
		#if desktop
		#if DISCORD_ALLOWED DiscordClient.changePresence('Browsing the menus', null); #end
		WindowUtil.title = ('%{GAME_TITLE} - Options');
		#end
		FlxG.mouse.visible = false;
		ClientPrefs.loadPreferences();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = EngineData.MENU_COLOR;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = funkin.backend.utils.ClientPrefs.data.antialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<funkin.game.objects.Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:funkin.game.objects.Alphabet = new funkin.game.objects.Alphabet(0, OFFSETFUCKME, options[i], true);
			optionText.screenCenter();
			optionText.astroMenuItem = true;
			// optionText.alignment = CENTERED;
			// optionText.changeY = false;
			optionText.changeX = false;
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new funkin.game.objects.Alphabet(0, OFFSETFUCKME, '>', true);
		selectorLeft.isMenuItem = true;
		selectorLeft.changeX = false;
		add(selectorLeft);
		selectorRight = new funkin.game.objects.Alphabet(0, OFFSETFUCKME, '<', true);
		selectorRight.isMenuItem = true;
		selectorRight.changeX = false;
		add(selectorRight);

		changeSelection();
		funkin.backend.utils.ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		funkin.backend.utils.ClientPrefs.saveSettings();
		#if desktop
		#if DISCORD_ALLOWED DiscordClient.changePresence('Browsing the menus', null); #end
		WindowUtil.title = ('%{GAME_TITLE} - Options');
		#end
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		else if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		else if (FlxG.mouse.wheel != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-FlxG.mouse.wheel, false);
		}

		if (controls.ACCEPT || FlxG.mouse.justPressedMiddle)
		{
			openSelectedSubstate(options[curSelected]);
		}
		else if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
			MusicBeatState.switchState(new funkin.game.states.MainMenuState());
		}
	}

	function changeSelection(change:Int = 0, ?snd:Bool = true)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		if (snd)
			FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
