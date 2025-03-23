package funkin.backend.system.scripts.custom;

import openfl.text.TextFormatAlign;
#if HSCRIPT_ALLOWED
@:publicFields
class CustomFlxTextAlign//i hate hscript
{
	static var LEFT(default, null):FlxTextAlign = FlxTextAlign.LEFT;
	static var CENTER(default, null):FlxTextAlign = FlxTextAlign.CENTER;
	static var RIGHT(default, null):FlxTextAlign = FlxTextAlign.RIGHT;
	static var JUSTIFY(default, null):FlxTextAlign = FlxTextAlign.JUSTIFY;

	static function fromOpenFL(align:TextFormatAlign):FlxTextAlign
        return cast FlxTextAlign.fromOpenFL(align);

	static function toOpenFL(align:FlxTextAlign):TextFormatAlign
        return cast FlxTextAlign.toOpenFL(align);
}
#end