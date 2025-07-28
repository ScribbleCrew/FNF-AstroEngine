package funkin.backend.lunarUI;

import haxe.PosInfos;

class Alert
{
	static var manager:AlertManager = new AlertManager();

	/**
	 * Show a fully (**lies**) **customizable alert popup.
	 * @param title 
	 * @param shortDesc 
	 * @param longDesc 
	 */
	public static function show(title:String, shortDesc:String, longDesc:String):Void
	{
		manager.show({name: title, short: shortDesc, long: longDesc});
	}

	/**
	 * Show a error alert
	 * @param error 
	 * @param posInfos 
	 * @param customTitle 
	 */
	public static function error(error, ?posInfos:PosInfos, ?customTitle:String):Void
	{
		manager.show({
			name: customTitle ?? "ERROR!",
			short: '${posInfos.fileName ?? "duh.hx"}:${posInfos.lineNumber ?? 69}:${posInfos.methodName ?? "idfk"}',
			long: error
			/* idk the type */
		});
	}
}

typedef AlertManagerData =
{
	name:String,
	?short:String,
	long:String
}

class AlertManager
{
	var __camLoaded:Bool = false;
	var __list:Array<AlertObject> = [];

	public function new()
	{
	}

	public function show(data:AlertManagerData):Void
	{
		for (v in __list)
		{
			if (v == null)
				continue;
			v.y += 150;
		}

		final bruh = new AlertObject(200, 200, data);
		__list.push(bruh);
		// make fucking camera for dis
	}

	function showNoti(data:AlertManagerData):AlertObject
	{
		return new AlertObject();
	}

	function __createAlert(title, desc, ?posInfos:PosInfos, ?self:Bool = false):AlertObject
	{
		final duh = new AlertObject();

		return duh;
	}
}

// typedef AlertData =
// { // ima be honest i can't think of anything else to add here
// 	?title:String, // why
// 	error:String, // right??? errors are strings right????
// 	?posInfos:haxe.PosInfos,
// }
// todo: convert to a openfl sprite
//
class AlertObject extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	//
	//
	// TODO: be fucking stupid and make seperate cameras for each of these because DUH :3
	// DISCLAIMER: THIS IS UHH SHIT AND MESSY CODE SO FUCK OFF IF YOU CAN'T READ IT OR
	// IF IM USING THE SAME CODE MULTIPLE TIMES FOR NO FUCKING REASON OKAY!!!
	// IF YOU DON'T LIEK THIS JUST UHH MAKE A PR OR SMTH IDFK
	// im sorry :( -orbl
	//
	//
	//
	@:noCompletion var __oldPos:FlxPoint = new FlxPoint();

	var closeBtn:UIObject;
	var notiSpr:UISliceSprite;
	var titleSpr:UIText;
	var posInfos:UIText;
	var error:UIText;

	@:noCompletion inline static final xoff:Float = 20; // FFS

	public function new(?x = 0, ?y = 0, ?data:AlertManagerData):Void
	{
		super(x, y);

		alpha = 0;
		this.getPosition().copyTo(__oldPos);

		add(notiSpr = new UISliceSprite(0, 0, 300, 145, "ui/context-bg-darken-minus-border"));

		add(titleSpr = new UIText(0, notiSpr.y, notiSpr.bWidth - 50, data.name ?? "ERROR!", 15));
		titleSpr.size = 18;
		titleSpr.y = notiSpr.y + ((30 - titleSpr.height) / 2) + 5;
		titleSpr.x = __oldPos.x + 7.5;

		if (data.short != null)
		{
			add(posInfos = new UIText(0, notiSpr.y, notiSpr.bWidth - 10, data.short ?? "What the fuck", 14));
			posInfos.color = FlxColor.GRAY;
			posInfos.textField.wordWrap = false;
			posInfos.y = titleSpr.y + 20;
			posInfos.x = titleSpr.x;
		}

		add(error = new UIText(0, notiSpr.y, notiSpr.bWidth - 20, data.long ?? "undefined", 14));
		error.color = FlxColor.RED;
		error.fieldHeight = notiSpr.bHeight;
		error.y = (posInfos ?? titleSpr).y + 20;
		error.x = titleSpr.x;

		final UGH_TWEEN_TIME:Float = .6;

		// close button because YEAH!
		add(closeBtn = new UIObject(notiSpr.x + 25, notiSpr.y, Paths.image('ui/close-button')));
		closeBtn.y = notiSpr.y + ((30 - closeBtn.height) / 2);
		closeBtn.x = (notiSpr.x + notiSpr.bWidth) - (closeBtn.width + 10);
		closeBtn.focusChange.add((duh:Bool, ?that:UIObject) -> that.color = duh ? FlxColor.GRAY : FlxColor.WHITE);
		closeBtn.pressedCallback.add((?that:UIObject) ->
		{
			closeBtn.available = false;

			FlxTween.num(this.x, this.x - xoff, UGH_TWEEN_TIME, {ease: FlxEase.expoOut}, set_x);
			FlxTween.num(this.alpha, 0, UGH_TWEEN_TIME, {
				ease: FlxEase.expoOut,
				onComplete: _ -> destroy()
			}, set_alpha);
		});

		// ffs bitch
		// the fact that i can say "stfu" in roblox now is crazy
		this.x += xoff;

		// @:privateAccess { // shouldn't need a priv access but im to lazy to check :(
		FlxTween.num(this.x, __oldPos.x, UGH_TWEEN_TIME, {ease: FlxEase.expoOut}, set_x);
		FlxTween.num(this.alpha, 1, UGH_TWEEN_TIME, {ease: FlxEase.expoOut}, set_alpha);
		// }

		FlxG.state.add(this);
		//FlxG.game.addChild(new FlxSpriteBitmapMirror(this));

		notiSpr.bHeight = Std.int((error.y + error.height) - titleSpr.y);
	}

	// TODO: make btnObject class with option to follow a object
}
