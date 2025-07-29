package funkin.game.objects;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class FunkinText extends FlxText {
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 16, Border:Bool = true, ?Font:String) {
		super(X, Y, FieldWidth, Text, Size);
		setFormat(Font ?? Constants.DEFAULT_FONT, Size, FlxColor.WHITE);
		
		if (Border) {
			borderStyle = OUTLINE;
			borderSize = 1.25;
			borderColor = 0xFF000000;
		}
	}
}