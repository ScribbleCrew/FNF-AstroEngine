package funkin.game.states;

import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.AttachedFlxSprite;
import haxe.xml.Access;
#if desktop
import funkin.backend.client.Discord.DiscordClient;
#end
#if MODS_ALLOWED
import sys.FileSystem;
#end

typedef CreditsOptions =
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
	@:noCompletion static private final offsetThing:Float = -75;

	var curSelected:Int = -1;

	var intendedColor:Int;

	var grpOptions:FlxTypedGroup<funkin.game.objects.Alphabet>;
	var iconArray:Array<AttachedFlxSprite> = [];
	var creditsStuff:Array<CreditsOptions> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var descBox:AttachedFlxSprite;

	private inline function unselectableCheck(num:Int):Bool
		return creditsStuff[num].name == null || creditsStuff[num].name.length <= 1;

	override function create():Void
	{
		persistentUpdate = true;

		#if desktop
		#if DISCORD_ALLOWED DiscordClient.changePresence("Credits Menu", null); #end
		WindowUtil.setTitle('Credits Menu');
		FlxG.mouse.visible = false;
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<funkin.game.objects.Alphabet>();
		add(grpOptions);

		final filePath:String = 'data/credits.xml';
		grabXMLData(Paths.xmlAccess(filePath, false));
		#if MODS_ALLOWED
		for (mod in (Mods.parseList().enabled).concat(['']))
		{
			final creditsFile:String = Paths.mods(mod + '/$filePath');
			if (FileSystem.exists(creditsFile))
				grabXMLData(Paths.xmlAccess(creditsFile, true));
		}
		#end
		generateCredits();

		descBox = new AttachedFlxSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Constants.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);

		bg.color = colorFromIcon(creditsStuff);
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	function colorFromIcon(creditData:Array<CreditsOptions>):FlxColor
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

	private var quitting:Bool = false;
	private var holdTime:Float = 0;

	override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				final upP = controls.UI_UP_P;
				final downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				else if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}
				else if (FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if ((controls.ACCEPT || FlxG.mouse.justPressedMiddle)
				&& (creditsStuff[curSelected].link != null || creditsStuff[curSelected].link.length > 4))
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
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
			}
		}
		super.update(elapsed);
	}

	private function generateCredits():Void
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

				var str:String = 'credits/face';
				if (Paths.image('credits/' + creditsStuff[i].icon, false) != null)
					str = 'credits/' + creditsStuff[i].icon;

				var icon:AttachedFlxSprite = new AttachedFlxSprite(str, null, null, false, false);
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

	private function grabXMLData(access:Access):Void
	{
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
							name: try credit.att.name catch (_) "invalid",
							icon: try credit.att.icon catch (_) "face",
							description: try (credit.att.description != null ? credit.att.description.replace('\\n', '\n') : "") catch (_) "",
							link: try credit.att.link catch (_) null,
							color: try credit.att.color catch (_) null,
						});
					}
					creditsStuff.push({category: ""});
				}
			}
		}
		catch (e)
			trace('ERROR loading credits : $e');
	}

	private function changeSelection(change:Int = 0, ?snd:Bool = true):Void
	{
		if (snd)
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

		final newColor:FlxColor = colorFromIcon(creditsStuff);
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
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
					item.alpha = 1;
			}
		}

		descText.text = creditsStuff[curSelected].description;
		if (descText.text.trim().length > 0)
		{
			descText.visible = descBox.visible = true;
			descText.y = FlxG.height - descText.height + offsetThing - 60;

			FlxTween.cancelTweensOf(descText);
			FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		}
		else
			descText.visible = descBox.visible = false;
	}
}
