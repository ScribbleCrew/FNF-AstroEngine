package funkin.game.states;

import haxe.xml.Access;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.AttachedFlxSprite;
#if DISCORD_ALLOWED
import funkin.backend.client.Discord.DiscordClient;
#end
#if MODS_ALLOWED
import sys.FileSystem;
#end

private typedef CreditsOptions =
{
	@:optional var category:String;

	@:optional var name:String;
	@:optional var link:String;
	@:optional var icon:String;
	@:optional var description:String;
	@:optional var color:String;
	@:optional var directory:String;
}

class CreditsState extends MusicBeatState
{
	@:dox(hide) @:noCompletion static inline final __offset:Float = -75;

	@:noCompletion var curSelected:Int = -1;

	var intendedColor:Int;

	var grpOptions:FlxTypedGroup<funkin.game.objects.Alphabet>;
	var iconArray:Array<AttachedFlxSprite> = [];
	var creditsStuff:Array<CreditsOptions> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var descBox:AttachedFlxSprite;

	@:dox(hide) inline function unselectableCheck(num:Int):Bool
		return creditsStuff[num].name == null || creditsStuff[num].name.length <= 1;

	override function create():Void
	{
		#if desktop
		#if DISCORD_ALLOWED DiscordClient.changePresence("Credits Menu", null); #end
		WindowUtil.title = ('%{GAME_TITLE} - Credits Menu');
		FlxG.mouse.visible = false;
		#end

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<funkin.game.objects.Alphabet>();
		add(grpOptions);

		try
		{
			final filePath:String = 'data/credits.xml';
			requireCreditsData(filePath, false);
			#if MODS_ALLOWED
			for (mod in (Mods.parseList().enabled).concat(['']))
			{
				final creditsFile:String = Paths.mods(mod + '/$filePath');
				if (FileSystem.exists(creditsFile))
					requireCreditsData(creditsFile);
			}
			#end

			FlxG.log.notice('Successfully loaded credits.');
		}
		catch (e:Dynamic)
		{
			Logs.prefixedTrace('Error loading credits : $e', 'Credits State', RED);
			FlxG.log.error('Error loading credits : $e');
			#if (desktop && lime)
			lime.app.Application.current.window.alert(e, "Error!");
			#end
		}
		generateCredits();

		descBox = new AttachedFlxSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + __offset - 25, 1180, "", 32);
		descText.setFormat(Constants.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);

		bg.color = requireColorFromIcon(creditsStuff);
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	function requireColorFromIcon(creditData:Array<CreditsOptions>):FlxColor
	{
		var str:String = 'credits/face';
		if (Paths.image('credits/' + creditData[curSelected].icon, false) != null)
			str = 'credits/' + creditData[curSelected].icon;

		final icon:FlxSprite = new FlxSprite().loadGraphic(Paths.image(str));

		if (creditData[curSelected].color != null)
			return CoolUtil.colorFromString(creditData[curSelected].color);
		if (icon != null)
			return FlxColor.fromInt(CoolUtil.dominantColor(icon));

		return FlxColor.GRAY;
	}

	 var quitting:Bool = false;
	@:dox(hide)  var holdTime:Float = 0;

	@:dox(hide) override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music.volume < 0.7) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				final shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;

				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				else if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}
				else if (FlxG.mouse.wheel != 0)
					changeSelection(-shiftMult * FlxG.mouse.wheel);

				if (controls.UI_DOWN || controls.UI_UP)
				{
					function calcHoldTime():Int 
						return Math.floor((holdTime - 0.5) * 10);

					final checkLastHold:Int = calcHoldTime();
					holdTime += elapsed;
					final checkNewHold:Int = calcHoldTime();

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			}

			if ((controls.ACCEPT || FlxG.mouse.justPressedMiddle) && (creditsStuff[curSelected].link != null || creditsStuff[curSelected].link.length > 4))
				CoolUtil.browserLoad(creditsStuff[curSelected].link);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new funkin.game.states.MainMenuState());
			quitting = true;
		}

		for (item in grpOptions.members)
		{
			if (!item.bold)
			{
				final lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					final lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
			}
		}

		super.update(elapsed);
	}

	function generateCredits():Void
	{
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:funkin.game.objects.Alphabet = new funkin.game.objects.Alphabet(FlxG.width / 2, 300,
				(creditsStuff[i].name ?? (creditsStuff[i].category ?? "Invalid")), !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (creditsStuff[i].directory != null)
					Mods.currentModDirectory = creditsStuff[i].directory;

				final imagePath:String = Paths.image('credits/' + creditsStuff[i].icon, false) != null ? 'credits/' + creditsStuff[i].icon : 'credits/face';

				final icon:AttachedFlxSprite = new AttachedFlxSprite(imagePath, null, null, false, false);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
				iconArray.push(icon);
				add(icon);

				Mods.currentModDirectory = '';

				if (curSelected == -1)
					curSelected = i;
			}
			else
				optionText.alignment = funkin.game.objects.Alphabet.Alignment.CENTERED;
		}
	}

	 function requireCreditsData(path:String, mods:Bool = true):Void
	{
		final access = new Access(Xml.parse(mods ? File.getContent(path) : Paths.getTextFromFile(path, true)).firstElement());// i FUCKING HATE THIS SHIT

		try
		{
			if (access != null)
			{
				for (category in access.nodes.category)
				{
					creditsStuff.push({category: category.att.name});
					for (credit in category.nodes.credit)
					{
						creditsStuff.push({
							name: credit.has.name ? credit.att.name : "invalid",
							icon: credit.has.icon ? credit.att.icon : "face",
							description: credit.has.description ? (credit.att.description != null ? credit.att.description.replace('\\n', '\n') : "") : "",
							link: credit.has.link ? credit.att.link : null,
							color: credit.has.color ? credit.att.color : null,
						});
					}
					creditsStuff.push({category: ""});
				}
			}
		}
		catch (e:Dynamic)
			Logs.prefixedTrace(e, 'Credits State', RED);
	}

	 function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		final newColor:FlxColor = requireColorFromIcon(creditsStuff);
		if (newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}

		var bullShit:Int = 0;
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
				item.alpha = item.targetY == 0 ? 1 : .6;
		}

		descText.text = creditsStuff[curSelected].description;
		if (descText.text.trim().length > 0)
		{
			descText.visible = descBox.visible = true;
			descText.y = FlxG.height - descText.height + __offset - 60;

			FlxTween.cancelTweensOf(descText);
			FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		}
		else
			descText.visible = descBox.visible = false;
	}
}
