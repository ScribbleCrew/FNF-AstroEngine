package funkin.backend.system.initialization;
#if WATERMARK
import openfl.text.TextFormat;

/**
 * A stupid class, which can help reduce with mod leaking, by adding -DWATERMARK to your compile
 * params or enable it in Project.xml, and you'll get a watermark that displays the user's pc username.
 * discord name, and something else I forgot...
 */
class Watermark extends openfl.text.TextField
{
	@:noCompletion private var format:TextFormat;

	public function new()
	{
		super();

		format = new TextFormat(Paths.font('OswaldMedium.ttf'), 55, FlxColor.WHITE);
		format.align = openfl.text.TextFormatAlign.CENTER;

		defaultTextFormat = format;
		text = OsAPI.username;
		alpha = .55;
		width = FlxG.width;
		selectable = false;
		y = (FlxG.height - textHeight) / 2;
	}
}
#end
