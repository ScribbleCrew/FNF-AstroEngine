package funkin.game.states.options.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.objects.Alphabet;
import funkin.backend.data.*;
import funkin.backend.system.MusicBeatSubstate;
import funkin.backend.utils.Paths;
#if desktop
import funkin.backend.client.Discord.DiscordClient;
#end

class StatsSubState extends BaseMenu
{
	private var text:FlxText;
	private var textBG:FlxSprite;

	private var statsTxt:funkin.game.objects.Alphabet;
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var curSelected:Int = 0;

	// dont ask questions :3c
	private final statID:Array<String> = [for (i in ClientPrefs.data.stats.keys()) i];

	public function new()
	{
		super();

		ClientPrefs.loadPrefs();

		#if desktop
		DiscordClient.changePresence('Viewing Stats', null);
		WindowUtil.setTitle('Options - Stats');
		#end

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		regenStats();

		textBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.scrollFactor.set(0, 0);
		textBG.alpha = 0.6;
		add(textBG);

		text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Press RESET to clear stats!", 18);
		text.setFormat(Constants.DEFAULT_FONT, 18, FlxColor.WHITE, CENTER);
		text.scrollFactor.set(0, 0);
		add(text);

		changeSelection();
	}

	function regenStats()
	{
		grpTexts.clear();
		for (i in 0...statID.length)
		{
			statsTxt = new Alphabet(0, 200, "N/A: 0000", false);
			statsTxt.screenCenter();
			statsTxt.text = statID[i] + ": " + ClientPrefs.data.stats.get(statID[i]);
			statsTxt.screenCenter();
			statsTxt.astroMenuItem = true;
			statsTxt.changeX = false;
			statsTxt.targetY = i;
			statsTxt.ID = i;
			statsTxt.changeX = false;
			grpTexts.add(statsTxt);
		}
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.saveSettings();
		}

		if (controls.RESET)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.data.stats.resetMap(0);
			ClientPrefs.saveSettings();
			regenStats();
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = statID.length - 1;
		if (curSelected >= statID.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.ID == curSelected)
			{
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
