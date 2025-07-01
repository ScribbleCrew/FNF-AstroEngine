package funkin.backend.framerate.addons;

import openfl.text.TextFormat;
import openfl.display.Sprite;
import openfl.text.TextField;

class Memory extends FContainerField {
	public var memText:TextField;
	public var memFTText:TextField;

	public var memory:Float = 0;
	public var memoryPeak:Float = 0;

	public function new() {
		super();

		memText = new TextField();
		memFTText = new TextField();

		for(label in [memText, memFTText]) {
			label.autoSize = LEFT;
			label.x = 0;
			label.y = 0;
			label.text = "FPS";
			label.multiline = label.wordWrap = false;
			label.defaultTextFormat = new TextFormat(FramerateContainer.fontName, 12, -1);
			label.selectable = false;
			addChild(label);
		}
		memFTText.alpha = 0.5;
	}

	@:noCompletion
	override function __enterFrame(t:Int) : Void {
		super.__enterFrame(t);

		memory = MemoryUtil.currentMemUsage();
		if (memoryPeak < memory) memoryPeak = memory;
		memText.text = CoolUtil.getSizeString(memory);
		memFTText.text = ' / ${CoolUtil.getSizeString(memoryPeak)}';

		memFTText.x = memText.x + memText.width;
	}
}
