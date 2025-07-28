package funkin.backend.lunarUI;

import funkin.backend.system.MusicBeatState;

class UIState extends MusicBeatState
{
	public static var state(get, never):UIState;

	@:noCompletion static function get_state():UIState
		return FlxG.state is UIState ? cast FlxG.state : null;

	public function new(?camera_controls:Bool):Void
	{
		__CAMERA_CONTROLS = camera_controls; // maybe make a flag system ["CAMERA_CONTROLS", "e.g"]
		super();
	}

	public var focus(get,never):FlxBasic;
	@:noCompletion function get_focus() : FlxBasic
		return __focus;

	@:noCompletion var __focus:FlxBasic = null;

	@:noCompletion var __CAMERA_CONTROLS:Bool = true;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (__CAMERA_CONTROLS)
		{
			var shiftMult:Float = 1;
			var ctrlMult:Float = 1;
			var shiftMultBig:Float = 1;
			if (FlxG.keys.pressed.SHIFT)
			{
				shiftMult = 4;
				shiftMultBig = 10;
			}
			if (FlxG.keys.pressed.CONTROL)
				ctrlMult = 0.25;

			// CAMERA CONTROLS
			if (FlxG.keys.pressed.J)
				FlxG.camera.scroll.x -= elapsed * 500 * shiftMult * ctrlMult;
			if (FlxG.keys.pressed.K)
				FlxG.camera.scroll.y += elapsed * 500 * shiftMult * ctrlMult;
			if (FlxG.keys.pressed.L)
				FlxG.camera.scroll.x += elapsed * 500 * shiftMult * ctrlMult;
			if (FlxG.keys.pressed.I)
				FlxG.camera.scroll.y -= elapsed * 500 * shiftMult * ctrlMult;

			var lastZoom = FlxG.camera.zoom;
			if (FlxG.keys.justPressed.R && !FlxG.keys.pressed.CONTROL)
				FlxG.camera.zoom = 1;
			else if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
			{
				FlxG.camera.zoom += elapsed * FlxG.camera.zoom * shiftMult * ctrlMult;
				if (FlxG.camera.zoom > 3)
					FlxG.camera.zoom = 3;
			}
			else if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
			{
				FlxG.camera.zoom -= elapsed * FlxG.camera.zoom * shiftMult * ctrlMult;
				if (FlxG.camera.zoom < 0.1)
					FlxG.camera.zoom = 0.1;
			}
		}
	}
}
