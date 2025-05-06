package funkin.game.states.options.substates;

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

class VisualsUISubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;

	public function new():Void
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence

		notes = new FlxTypedGroup<StrumNote>();
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}

		// options

		var noteSkins:Array<String> = Mods.mergeAllTextsNamed('data/notes/skin/list.txt');
		if (noteSkins.length > 0)
		{
			if (!noteSkins.contains(ClientPrefs.data.noteSkin))
				ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; // Reset to default if saved noteskin couldnt be found

			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); // Default skin always comes first
			var option:Option = new Option('Note Skins:', "Select your prefered Note skin.", 'noteSkin', STRING, noteSkins);
			addOption(option);
			option.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}
		
		final uhh = Mods.mergeAllTextsNamed('data/interfaceOptions.txt');
		if(uhh.length > 0){
			if(!uhh.contains(ClientPrefs.data.interfaceType))
				ClientPrefs.data.interfaceType = ClientPrefs.defaultData.interfaceType;
			addOption(new Option('User Interface:', "What user interface would you like?", 'interfaceType', STRING, uhh));
		}

		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('data/notes/splashes/list.txt');
		if (noteSplashes.length > 0)
		{
			if (!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; // Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(1, ClientPrefs.defaultData.splashSkin); // Default skin always comes first
			var option:Option = new Option('Note Splashes:', "Select your prefered Note Splash variation or turn it off.", 'splashSkin', STRING, noteSplashes);
			addOption(option);
		}

		var holdSkins:Array<String> = Mods.mergeAllTextsNamed('data/notes/covers/list.txt');
		if(holdSkins.length > 0)
		{
			if(!holdSkins.contains(ClientPrefs.data.holdSkin))
				ClientPrefs.data.holdSkin = ClientPrefs.defaultData.holdSkin; //Reset to default if saved splashskin couldnt be found
			holdSkins.remove(ClientPrefs.defaultData.holdSkin);
			holdSkins.insert(0, ClientPrefs.defaultData.holdSkin); //Default skin always comes first
			var option:Option = new Option('Hold Splashes:',
				"Select your preferred Hold Splash variation or turn it off.",
				'holdSkin',
				STRING,
				holdSkins);
			addOption(option);
		}

		addOption(new Option('Time Bar:', "What should the Time Bar display?", 'timeBarType', STRING, ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']));

		var option:Option = new Option('Hide HUD', 'Hide\'s all HUD elements\nimproves performance.', 'hideHud', BOOL);
		addOption(option);
		option.onChange = () ->
		{
			ClientPrefs.data.showFPS = !ClientPrefs.data.hideHud;

			if (funkin.game.Main.framerateCounter != null)
				funkin.game.Main.framerateCounter.visible = ClientPrefs.data.showFPS;
		};

		addOption(new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', BOOL));
		addOption(new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', BOOL));
		addOption(new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom', BOOL));

		final option:Option = new Option('Health Bar Opacity', 'How much transparent should the health bar and icons be.', 'healthBarAlpha', PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Note Hold Splash Opacity',
		'How much transparent should the Note Hold Splash be.\n0% disables it.',
		'holdSplashAlpha',
		PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		#if !mobile
		final option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', 'showFPS', BOOL);
		option.onChange = () ->
		{
			funkin.backend.utils.ClientPrefs.data.hideHud = !funkin.backend.utils.ClientPrefs.data.showFPS;

			if (funkin.game.Main.framerateCounter != null)
				funkin.game.Main.framerateCounter.visible = funkin.backend.utils.ClientPrefs.data.showFPS;
		};
		addOption(option);

		var option:Option = new Option('FPS Counter Opacity', 'The transparency of the FPS counter.', 'fpsCounterAlpha', PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () -> @:privateAccess FlxTween.num(Main.framerateCounter.alpha, ClientPrefs.data.fpsCounterAlpha, .1, {ease: FlxEase.expoOut},
			Main.framerateCounter.set_alpha);
		addOption(option);
		#end

		var option:Option = new Option('Pause Screen Song:', "What song do you prefer for the Pause Screen?", 'pauseMusic', STRING,
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = () ->
		{
			if (funkin.backend.utils.ClientPrefs.data.pauseMusic == 'None')
				FlxG.sound.music.volume = 0;
			else
				FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(funkin.backend.utils.ClientPrefs.data.pauseMusic)));

			changedMusic = true;
		};

		#if CHECK_FOR_UPDATES
		addOption(new Option('Check for Updates', 'On Release builds, turn this on to check for updates when you start the game.', 'checkForUpdates', BOOL));
		#end
		addOption(new Option('Combo Stacking', "If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking', BOOL));

		super();
		add(notes);
	}

	override function changeSelection(change:Int = 0, ?snd:Bool = true):Void
	{
		super.changeSelection(change, snd);

		if (noteOptionID < 0)
			return;

		for (i in 0...Note.colArray.length)
		{
			final note:StrumNote = notes.members[i];
			if (notesTween[i] != null)
				notesTween[i].cancel();

			notesTween[i] = FlxTween.tween(note, {y: curSelected == noteOptionID ? noteY : -200}, Math.abs(note.y / (200 + noteY)) / 3,
				{ease: FlxEase.quadInOut});
		}
	}

	function onChangeNoteSkin():Void
	{
		notes.forEachAlive(function(note:StrumNote)
		{
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function changeNoteSkin(note:StrumNote):Void
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if (Paths.fileExists('images/$customSkin.png', IMAGE))
			skin = customSkin;

		note.texture = skin; // Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	var changedMusic:Bool = false;

	override function destroy():Void
	{
		if (changedMusic)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}
}
