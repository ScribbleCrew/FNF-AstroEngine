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
		contextBox.centerScreen();
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

		if(FlxG.keys.justPressed.F8)
			openSubState(new WindowPopup(FlxG.width-400, FlxG.height-200, "Test 3.2.1. (kisser) <:3>:3<:3>", (state:WindowPopup)->{
				state.persistentDraw = true;
				state.persistentUpdate = true;

				state._windowTitle.applyMarkup(state._windowTitle.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFA6FB), "<:3>")]);
				state._windowTitle.textField.antiAliasType = openfl.text.AntiAliasType.ADVANCED;
				state._windowTitle.textField.sharpness = 400;

				var spr; state.add(spr = new FlxSprite(0,0,Paths.image('extra/kisser')));
				spr.cameras = state.cameras; state._windowBackground.centerSpriteOnThis(spr);
			}));

	}

	//override 
}
