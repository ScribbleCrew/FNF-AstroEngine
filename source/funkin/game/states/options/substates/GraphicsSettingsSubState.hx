package funkin.game.states.options.substates;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.backend.utils.ClientPrefs;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var boyfriend:Character;

	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function(name:String) boyfriend.dance();
		boyfriend.visible = false;

		final lowQualityOption:Option = new Option('Low Quality', 'If checked, disables some background details,\ndecreases loading times and improves performance.',
			'lowQuality', BOOL);
		addOption(lowQualityOption);

		final antialiasingOption:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing', BOOL);
			antialiasingOption.onChange = () ->
		{
			for (sprite in members)
			{
				var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
				var sprite:FlxSprite = sprite; // Don't judge me ok
				if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
					sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		};
		antialiasingOption.onMove = (selected:Bool) -> boyfriend.visible = selected;
		addOption(antialiasingOption);

		#if (WINDOW_CUSTOMIZATION && windows)
		var darkmodeOption:Option = new Option('Dark Mode', 'Enabled Dark Mode Support.', 'darkmodeEnabled', BOOL);
		darkmodeOption.onChange = () -> WindowUtil.darkmode = ClientPrefs.data.darkmodeEnabled;
		addOption(darkmodeOption);
		#end

		#if SHADERS_ALLOWED
		var ShadersOption:Option = new Option('Shaders', // Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', // Description
			'shaders', // Save data variable name
			BOOL); // Default value
		addOption(ShadersOption);
		#end
		
		final gpuCachingOption:Option = new Option('GPU Caching', // Name
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", // Description
			'cacheOnGPU', BOOL);
		addOption(gpuCachingOption);

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		final framerateOption:Option = new Option('Framerate', "Pretty self explanatory, isn't it?", 'framerate', INT);
		addOption(framerateOption);
		framerateOption.minValue = 60;
		framerateOption.maxValue = 240;
		framerateOption.defaultValue = Std.int(FlxMath.bound(FlxG.stage.application.window.displayMode.refreshRate, framerateOption.minValue, framerateOption.maxValue));
		framerateOption.displayFormat = '%v FPS';
		framerateOption.onChange = () ->
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
		insert(999, boyfriend);
	}

	override function destroy() : Void {
		boyfriend = FlxDestroyUtil.destroy(boyfriend);
		super.destroy();
	}
}
