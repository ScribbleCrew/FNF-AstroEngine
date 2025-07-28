package funkin.backend.lunarUI;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.util.FlxSignal.FlxTypedSignal;

// TODO: have a UIState focus + boolean to chose to follow focus rules 
// Which means if you have it false you can have `UIState.state.focus = spr` be active and `spr` be active
// im sorry, im awful at explaining stuffz
class UIObject extends FlxSprite
{
	public var focused:Bool = false;

	public var members:Array<FlxBasic> = [];

	@:noCompletion public function __add(v:FlxBasic):Void
		members.push(v);

	@:noCompletion public function __drawMembers():Void @:privateAccess {
		for (i in members)
			if (i.active && i.visible)
				if (i.draw != null)
					i.draw();
	}

	public var available:Bool = true;

	@:noCompletion override function destroy():Void
	{
		members = FlxDestroyUtil.destroyArray(members);
		super.destroy();
	}

	// WHEN YOU FUCKING CLICK BITCH
	public var pressedCallback:FlxTypedSignal<?UIObject->Void> = new FlxTypedSignal();
	
	// WHEN YOU FUCKING HOVER OR SMTH OR WHEN YOU DOn'T FUCKING UHHH
	public var focusChange:FlxTypedSignal<(Bool, ?UIObject) -> Void> = new FlxTypedSignal();

	@:noCompletion var __prevFocus:Bool = false;

	@:dox(hide) override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		__prevFocus = focused;
		focused = false;
		if (CoolUtil.mouseOverlapping(this))
		{
			focused = true;
			if (FlxG.mouse.justPressed)
				if (pressedCallback != null && available)
					pressedCallback.dispatch(this);
		}

		if (__prevFocus != focused && focusChange != null && available)
			focusChange.dispatch(focused, this);
	}
}
