package funkin.game.states.options.substates;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.backend.utils.ClientPrefs;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		var boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function(name:String) boyfriend.dance();
		boyfriend.visible = false;

		var option:Option = new Option('Low Quality', 'If checked, disables some background details,\ndecreases loading times and improves performance.',
			'lowQuality', BOOL);
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing', BOOL);
		option.onChange = () ->
		{
			for (sprite in members)
			{
				var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
				var sprite:FlxSprite = sprite; // Don't judge me ok
				if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
					sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		};
		option.onMove = (selected:Bool) -> boyfriend.visible = selected;
		addOption(option);

		#if (WINDOW_CUSTOMIZATION && windows)
		var option:Option = new Option('Dark Mode', 'Enabled Dark Mode Support.', 'darkmodeEnabled', BOOL);
		option.onChange = () -> WindowUtil.darkmode = ClientPrefs.data.darkmodeEnabled;
		addOption(option);
		#end

		#if SHADERS_ALLOWED
		var option:Option = new Option('Shaders', // Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', // Description
			'shaders', // Save data variable name
			BOOL); // Default value
		addOption(option);
		#end

		var option:Option = new Option('GPU Caching', // Name
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", // Description
			'cacheOnGPU', BOOL);
		addOption(option);

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate', "Pretty self explanatory, isn't it?", 'framerate', INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 60;
		option.maxValue = 240;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = () ->
		{
			if (ClientPrefs.data.framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = ClientPrefs.data.framerate;
				FlxG.drawFramerate = ClientPrefs.data.framerate;
			}
			else
			{
				FlxG.drawFramerate = ClientPrefs.data.framerate;
				FlxG.updateFramerate = ClientPrefs.data.framerate;
			}
		};
		#end

		super();
		insert(1, boyfriend);
	}

	override function changeSelection(change:Int = 0, ?snd:Bool = true)
	{
		super.changeSelection(change, snd);
	}
}
