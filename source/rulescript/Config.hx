package rulescript;

/**
* For rulescripted classes stuff
*/
@:publicFields
class Config
{
	static final CUSTOM_CLASSES_SHADOW_SUFFIX:String = '_RSC';

	static final ALLOWED_CUSTOM_CLASSES:Array<String> = [// IMPORTANT: ADD NEEDED CLASSES TO THIS...
		"flixel.FlxSprite",
		"flixel.text.FlxText",

		"funkin.game.objects.BGSprite",
		"funkin.game.objects.AttachedSprite",
		"funkin.game.objects.Bar",
		"funkin.game.objects.HealthIcon",
		"funkin.game.objects.MenuItem",

		"funkin.backend.base.UserInterface",// maybe add "--STRICT" flag

		// STATE SYSTEMS
		"funkin.backend.system.MusicBeatState",
		"funkin.backend.system.MusicBeatSubState",
	];

	static final DISALLOW_CUSTOM_CLASSES:Array<String> = [
		"flixel.addons.display.FlxShaderMaskCamera",
		"flixel.addons.display.FlxSpriteAniRot",
		"flixel.addons.display.FlxStarField",
		"flixel.addons.display.FlxZoomCamera",
		"flixel.system",
		"flixel.tweens",
		"flixel.system.macros",
		"flixel.input",
		//"funkin.game.objects.AchievementPopup"
		"flixel.system.macros.FlxMacroUtil"
	];
}
