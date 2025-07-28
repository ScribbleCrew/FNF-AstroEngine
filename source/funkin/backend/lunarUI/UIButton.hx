package funkin.backend.lunarUI;

// TODO: make slice btns for this, no need to add the hover/click handlers since thats all handled by UIObject
class UIButton extends UIObject
{ // TODO: allow spritesheet buttons instead of single images
    public var highQual:Bool = true;
	public function new(x:Float = 0.0, y:Float = 0.0, image:String)
	{
		super(x, y, Paths.image(image));
     
	/*	focusChange.add((duh) ->
		{
            // using scale.x as a placeholder since scale.x and scale.y will always be the same
            
           // if(highQual) FlxTween.num(scale.x, duh ? 1.2 : 1, .1, {ease: FlxEase.expoOut}, this.__setWholeScale); 
           // if(!highQual) color = duh ? FlxColor.WHITE : FlxColor.GRAY;
        }); */
	}


    /*
	function __setWholeScale(v1:Float):Float
		return this.scale.x = this.scale.y = v1; */
}
