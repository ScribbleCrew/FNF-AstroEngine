package funkin.game.states;

#if desktop
import funkin.backend.client.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import funkin.backend.utils.Controls;
import funkin.game.options.*;
import funkin.backend.system.MusicBeatSubstate;
import funkin.backend.system.MusicBeatState;

class OptionsState extends MusicBeatState
{
	public static var menuBG:FlxSprite;

	private final options:Array<String> = [
		'Note Colors',
		'Controls',
		'Graphics',
		'Gameplay',
		'Stats',
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
			case 'Stats':
				openSubState(new StatsSubState());
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
		DiscordClient.changePresence('Options Menu', null);
		WindowUtil.setTitle('Options');
		#end
		FlxG.mouse.visible = false;
		ClientPrefs.loadPrefs();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = EngineData.coreGame.menuColor;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = funkin.backend.utils.ClientPrefs.data.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<funkin.game.objects.Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:funkin.game.objects.Alphabet = new funkin.game.objects.Alphabet(0, OFFSETFUCKME, options[i], true);
			optionText.screenCenter();
			optionText.astroMenuItem = true;
			//optionText.alignment = CENTERED;
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
		DiscordClient.changePresence('Options Menu', null);
		WindowUtil.setTitle('Options');
		#end
	}

	override function update(elapsed:Float)
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
	

		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
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
