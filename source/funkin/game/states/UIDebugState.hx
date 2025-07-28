package funkin.game.states;

import funkin.backend.lunarUI.AlertObject.Alert;

class UIDebugState extends UIState
{
	public function new():Void
	{
		super(true); // enables camera controls
	}

	override public function create():Void
	{
		add(new FlxSprite(0, 0, Paths.image('menuBGBlue')).screenCenter());

		final contextBox = new UISliceSprite(0, 0, 300, 200, 'ui/context-bg');
		contextBox.scrollFactor.set(1, 1);
		contextBox.sCenter();
		add(contextBox);

		// for(i in 1...4)// makes 3 i thonk
		Alert.error('MASSIVE ERROR WHAT THE RFUCK', {
			fileName: "yeah.hx",
			lineNumber: 255,
			className: "lunarDoc",
			methodName: "WHAT:void"
		});

		// typedef PosInfos = {
		// var fileName:String;
		// var lineNumber:Int;
		// var className:String;
		// var methodName:String;
		// var ?customParams:Array<Dynamic>;
		// }

		//			add(new AlertObject(200,150));
	}

	
	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.justPressed.F9)
			Alert.error('MASSIVE ERROR WHAT THE RFUCK', {
				fileName: "yeah.hx",
				lineNumber: 255,
				className: "lunarDoc",
				methodName: "WHAT:void"
			});

	}

	//override 
}
