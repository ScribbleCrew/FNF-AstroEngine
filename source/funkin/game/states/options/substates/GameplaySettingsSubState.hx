package funkin.game.states.options.substates;

import funkin.backend.framerate.FramerateContainer;
import funkin.backend.framerate.addons.Framerate;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Controller Mode', 'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode', BOOL);
		addOption(option);

		var option:Option = new Option('Mouse Controls', 'If checked, mouse support will be enabled, simple right?', 'mouseEvents', BOOL);
		addOption(option);

		// I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', // Name
			'If checked, notes go Down instead of Up, simple enough.', // Description
			'downScroll', // Save data variable name
			BOOL); // Default value
		addOption(option);

		var option:Option = new Option('Middlescroll', 'If checked, your notes get centered.', 'middleScroll', BOOL);
		addOption(option);

		addOption(new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", 'noteSplashes', BOOL));
		addOption(new Option('Hold Splashes', "If unchecked, hold splashes wont-, uhh, splash?", 'holdCovers', BOOL));

		addOption(new Option('Opponent Note Splashes', "It's in the fucking name nerd", 'oppNoteSplashes', BOOL));
		addOption(new Option('Opponent Hold Splashes', "It's in the fucking name nerd", 'oppHoldSplashes', BOOL));

		addOption(new Option('Cursing', "aww, the baby doesn't like bad words?", 'cursing', BOOL));

		if (ClientPrefs.data.interfaceType == 'Astro') addOption(new Option('Rating Stats', "Show Rating Stats", 'showRatingStats', BOOL));

		/**
		 * Opponent notes
		 * If unchecked, opponent notes get hidden.
		 * They also get hidden by `data.hideHud`	
		 */
		addOption(new Option('Opponent Notes', 'If unchecked, opponent notes get hidden.', 'opponentStrums', BOOL));


		/**
		 * Ghost Tapping
		 * If checked, you won't get misses from pressing keys
		 * while there are no notes able to be hit.
		 */
		addOption(new Option('Ghost Tapping', "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.", 'ghostTapping', BOOL));

		/**
		* Disable Reset Button
		* If checked, pressing the reset button wont do anything...	
		*/
		addOption(new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", 'noReset', BOOL));

		#if DISCORD_ALLOWED
		var option:Option;
		addOption(option = new Option('Discord Rich Presence', "Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord", 'discordRPC', BOOL) );
		option.onChange = () -> ClientPrefs.data.discordRPC ? DiscordClient.initialize() : DiscordClient.shutdown();
		#end

		var option:Option = new Option('Hitsound Volume', 'Funny notes does \"Tick!\" when you hit them."', 'hitsoundVolume', PERCENT);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () -> FlxG.sound.play(Paths.sound('hitsound'), funkin.backend.utils.ClientPrefs.data.hitsoundVolume);

		var option:Option = new Option('Rating Offset', 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset', INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window', 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', 'sickWindow', INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window', 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', 'goodWindow', INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window', 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', 'badWindow', INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames', 'Changes how many frames you have for\nhitting a note earlier or late.', 'safeFrames', FLOAT);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		#if ASTRO_WATERMARKS var hehe:Option = null; 
		addOption(hehe = new Option('goob', null, 'goober', BOOL)); 
		@:privateAccess hehe.onChange = FramerateContainer.instance.fpsCounter._checkF; // did u wash your ass tonight
		#end

		super();
	}
}
