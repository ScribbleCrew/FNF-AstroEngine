package funkin.backend.lunarUI;

class UIText extends FunkinText
{
	public function new(X:Float = 0, Y:Float = 0, ?FieldWidth:Float = 0, ?Text:String, ?Size:Int = 16, ?Color:Int = -1) : Void
	{
		super(X, Y, FieldWidth, Text, Size);
		color = Color;

		alive = active = antialiasing = false;
	}
}
