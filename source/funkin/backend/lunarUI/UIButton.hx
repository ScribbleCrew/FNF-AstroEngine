package funkin.backend.lunarUI;

import openfl.ui.MouseCursor;

// TODO: make slice btns for this, no need to add the hover/click handlers since thats all handled by UIObject
class UIButton extends UIObject { // TODO: allow spritesheet buttons instead of single images
	//	public var highQual:Bool = true;
	// use an Either2 String or What Ever Type AtlasFrames Uses

	public function new(x:Float = 0.0, y:Float = 0.0, image:String) {
		super(x, y, Paths.image(image));

	//	focusChange.add((_, ?__) -> cursor = _ ? MouseCursor.BUTTON : MouseCursor.ARROW);

		/*	focusChange.add((duh) ->
			{
				// using scale.x as a placeholder since scale.x and scale.y will always be the same
				
			   // if(highQual) FlxTween.num(scale.x, duh ? 1.2 : 1, .1, {ease: FlxEase.expoOut}, this.__setWholeScale); 
			   // if(!highQual) color = duh ? FlxColor.WHITE : FlxColor.GRAY;
		});*/

		cursor = BUTTON;
	}
	/*
		function __setWholeScale(v1:Float):Float
			return this.scale.x = this.scale.y = v1; */
}
