package funkin.modding.objects;

interface IModSprite {
	public function playAnim(name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0):Void;
	public function addOffset(name:String, x:Float, y:Float):Void;
}

class ModchartSprite extends FlxSprite implements IModSprite
{
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	public function new(?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public function playAnim(name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0):Void
	{
		animation.play(name, forced, reverse, startFrame);
		
		final daOffset = animOffsets.get(name);
		if (animOffsets.exists(name)) offset.set(daOffset[0], daOffset[1]);
	}

	public function addOffset(name:String, x:Float, y:Float):Void
		animOffsets.set(name, [x, y]);
}

#if flxanimate
class ModchartAnimateSprite extends FlxAnimate implements IModSprite
{
	/**
	* Map of animation offsets.	
	*/
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	
	// super
	public function new(?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	/**
	* Play an Animation.	
	*/
	public function playAnim(name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0):Void
	{
		anim.play(name, forced, reverse, startFrame);
		
		var daOffset = animOffsets.get(name);
		if (animOffsets.exists(name)) offset.set(daOffset[0], daOffset[1]);
	}

	/**
	* Add an offset.	
	*/
	public function addOffset(name:String, x:Float, y:Float):Void
		animOffsets.set(name, [x, y]);
}
#end