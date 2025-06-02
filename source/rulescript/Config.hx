package rulescript;

/**
* For rulescripted classes stuff
*/
@:publicFields
class Config
{
	static final CUSTOM_CLASSES_SHADOW_PREFIX:String = '_RSC';

	static final ALLOWED_CUSTOM_CLASSES:Array<String> = [
		"flixel.FlxSprite",
		"funkin.game.objects.AchievementPopup"
	];

	static final DISALLOW_CUSTOM_CLASSES:Array<String> = [
		"flixel.addons.display.FlxShaderMaskCamera",
		"flixel.addons.display.FlxSpriteAniRot",
		"flixel.addons.display.FlxStarField",
		"flixel.addons.display.FlxZoomCamera",
		"flixel.system",
		"flixel.tweens",
	//	"flixel.system.macros",
		"flixel.input",
		"funkin.game.objects.AchievementPopup"
		//"flixel.system.macros.FlxMacroUtil"
	];
}
