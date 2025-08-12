package funkin.backend.framerate;
// inspired by codename, i really love what theyve done ^-^
//import haxe.ds.StringMap;
import openfl.text.Font;
import funkin.backend.framerate.addons.*;

@:font('assets/embed/fonts/engine/Source-Code-Pro.ttf')
class SourceCodePro extends openfl.text.Font {} // was called "FUCKYOU" but ive had a change of heart...

class FramerateContainer extends Sprite
{
	public static var instance:FramerateContainer = null;
	public static var fontName:String = "Source Code Pro Regular";//Paths.font('engine/SourceCodePro-Regular.ttf');//#if windows Paths.font('engine/SourceCodePro-Regular.ttf') #else Paths.font('engine/SourceCodePro-Regular.ttf') #end; // should we inline dis?

	public var fpsCounter:Framerate = null;
	public var memCounter:Memory = null;

//	public var objMap:Map<String, DisplayObject> = new Map<String, DisplayObject>(); // using this will require the use of casting but :p

	public function new():Void
	{
		// fuck u
		Font.registerFont(SourceCodePro);

		super();

		if (instance != null) throw "fuck off";
		instance = this;

		__pushList(fpsCounter = new Framerate());
        __pushList(memCounter = new Memory());
		__pushList(new EngineVersion());

		//var duh:Framerate = cast(objMap.get('Framerate'), Framerate);
		//if (duh != null)
		//	trace(duh.fpsLabel.text); // testing :p
	}

	static inline final __prevS:Int = 4;

	var _prevSpr:DisplayObject = null;

	function __pushList(spr:DisplayObject) : Void // :DisplayObject return em???
	{
		// if (spr.type == 'invalid')
		// 	throw 'dude the type cannot be invalid :p';
		spr.x = 0;
		spr.y = _prevSpr != null ? (_prevSpr.height + _prevSpr.y) : __prevS;
		_prevSpr = spr;
		addChild(spr);
		//		trace(Type.getClassName(Type.getClass(spr)));
		//objMap.set(CoolUtil.getClassName(spr), spr);
		// return spr;
	}

	public static var offset:FlxPoint = new FlxPoint();

	@:noCompletion
	override function __enterFrame(t:Int) : Void {
		alpha = CoolUtil.fpsLerp(alpha, 1 > 0 ? 1 : 0, 0.5);

		if (alpha < 0.05) return;
		super.__enterFrame(t);

		x = 12.5 + offset.x;
		y = 2 + offset.y;
	}
}
