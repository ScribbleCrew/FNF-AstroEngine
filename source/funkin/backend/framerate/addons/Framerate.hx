package funkin.backend.framerate.addons;

class Framerate extends FContainerField
{
	var __pf:Float = 0;

	public var fpsNum:TextField;
	public var fpsLabel:TextField;

	public function new():Void
	{
		super();

		fpsNum = new TextField();
		fpsLabel = new TextField();
		for (label in [fpsNum, fpsLabel])
		{
			label.autoSize = LEFT;
			label.x = label.y = 0;

			(label == fpsLabel) ? _checkF() : label.text = 'FPS';
			label.multiline = label.wordWrap = false;
			label.defaultTextFormat = new TextFormat(FramerateContainer.fontName, label == fpsNum ? 18 : 12, -1);
			label.selectable = false;
			addChild(label);
		}
	}

	public function _checkF():Void
	{
		fpsLabel.text = #if ASTRO_WATERMARKS ClientPrefs.data.goober ? "owo's per second" : #end "FPS";
	}

	@:noCompletion
	override function __enterFrame(whattt:Int):Void
	{
		super.__enterFrame(whattt);

		final elapsed:Float = FlxG.elapsed;
		final currentFPS:Float = (elapsed > 0) ? (1 / elapsed) : 0;
		__pf = CoolUtil.fpsLerp(__pf, currentFPS, 0.25);
		fpsNum.text = Std.string(Math.floor(__pf));

		fpsLabel.x = fpsNum.x + fpsNum.width;
		fpsLabel.y = (fpsNum.y + fpsNum.height) - fpsLabel.height;
	}
}
