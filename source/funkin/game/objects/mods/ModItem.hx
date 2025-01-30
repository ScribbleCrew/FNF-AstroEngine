package funkin.game.objects.mods;

import flixel.util.FlxSpriteUtil;
import flixel.util.FlxDestroyUtil;

class ModItem extends FlxSpriteGroup
{
	public var selectBg:FlxSprite;
	public var icon:FlxSprite;
	public var text:FlxText;
	public var totalFrames:Int = 0;

	// options
	public var name:String = 'Unknown Mod';
	public var desc:String = 'No description provided.';
	public var iconFps:Int = 10;
	public var bgColor:FlxColor = 0xFF665AFF;
	public var pack:Dynamic = null;
	public var folder:String = 'unknownMod';
	public var mustRestart:Bool = false;
	public var settings:Array<Dynamic> = null;

	public function new(folder:String)
	{
		super();

		this.folder = folder;
		pack = Mods.getPack(folder);

		var path:String = Paths.mods('$folder/data/settings.json');
		if (FileSystem.exists(path))
		{
			var data:String = File.getContent(path);
			try
			{
				// trace('trying to load settings: $folder');
				settings = tjson.TJSON.parse(data);
			}
			catch (e:Dynamic)
			{
				var errorTitle = 'Mod name: ' + Mods.currentModDirectory;
				var errorMsg = 'An error occurred: $e';
				#if windows
				lime.app.Application.current.window.alert(errorMsg, errorTitle);
				#end
				trace('$errorTitle - $errorMsg');
			}
			var errorTitle = 'Mod name: ' + Mods.currentModDirectory;
			var errorMsg = 'An error occurred: ';
			#if windows
			lime.app.Application.current.window.alert(errorMsg, errorTitle);
			#end
		}

	//	selectBg = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		selectBg = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite().makeGraphic(325+5, 80+5, FlxColor.TRANSPARENT), 0, 0, 325+5, 80+5, 15, 15, 15, 15, FlxColor.BLACK);
		selectBg.alpha = 0.6;
		selectBg.visible = false;
		selectBg.updateHitbox();
		add(selectBg);

		icon = new FlxSprite(5, 5);
		icon.antialiasing = ClientPrefs.data.antialiasing;
		add(icon);

		text = new FlxText(95, 38, 230, "", 16);
		text.setFormat(Constants.DEFAULT_FONT, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 2;
		text.y -= Std.int(text.height / 2);
		add(text);

		var isPixel = false;
		var file:String = Paths.mods('$folder/pack.png');
		if (!FileSystem.exists(file))
		{
			file = Paths.mods('$folder/pack-pixel.png');
			isPixel = true;
		}

		var bmp:BitmapData = null;
		if (FileSystem.exists(file))
			bmp = BitmapData.fromFile(file);
		else
			isPixel = false;

		if (FileSystem.exists(file))
		{
			icon.loadGraphic(Paths.cacheBitmap(file, bmp), true, 150, 150);
			if (isPixel)
				icon.antialiasing = false;
		}
		else
			icon.loadGraphic(Paths.image('unknownMod'), true, 150, 150);
		icon.scale.set(0.5, 0.5);
		icon.updateHitbox();
		icon.centerOnObject(selectBg, Y);

		this.name = folder;
		if (pack != null)
		{
			if (pack.name != null)
				this.name = pack.name;
			if (pack.description != null)
				this.desc = pack.description;
			if (pack.iconFramerate != null)
				this.iconFps = pack.iconFramerate;
			if (pack.color != null)
			{
				this.bgColor = FlxColor.fromRGB(pack.color[0] != null ? pack.color[0] : 170, pack.color[1] != null ? pack.color[1] : 0,
					pack.color[2] != null ? pack.color[2] : 255);
			}
			this.mustRestart = (pack.restart == true);
		}
		text.text = this.name;

		if (bmp != null)
		{
			totalFrames = Math.floor(bmp.width / 150) * Math.floor(bmp.height / 150);
			icon.animation.add("icon", [for (i in 0...totalFrames) i], iconFps);
			icon.animation.play("icon");
		}

		//selectBg = FlxSpriteUtil.drawRoundRectComplex(selectBg, 0, 0, 1, 1, 15, 15, 15, 15, FlxColor.BLACK);
		//selectBg.scale.set(width + 5, height + 5);
		//trace(width);
		//trace(height);
	//	selectBg.updateHitbox();
	}
}
