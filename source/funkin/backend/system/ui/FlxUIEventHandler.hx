package funkin.backend.system.ui;

class FlxUIEventHandler
{
	public static function event(id:String, sender:Dynamic)
	{
		var state:Dynamic = cast FlxG.state;
		if(state == null) return;

		while(state.subState != null)
			state = cast state.subState;

		if(state != null && state.UIEvent != null)
			state.UIEvent(id, sender);
	}
}

interface FlxUIEvent {
	public function UIEvent(id:String, sender:Dynamic):Void;
}