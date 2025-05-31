package rulescript;

/**
* For rulescripted classes stuff
*/
@:publicFields
class Config
{
	static final CUSTOM_CLASSES_SHADOW_PREFIX:String = '_RSCRIPT';

	static final ALLOWED_CUSTOM_CLASSES:Array<String> = [
	"flixel.FlxSprite"
	];

	static final DISALLOW_CUSTOM_CLASSES:Array<String> = [
		
	];
}
