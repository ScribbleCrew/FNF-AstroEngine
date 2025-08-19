package funkin.backend.lunarUI;

@:access(flixel.FlxCamera)
class WindowPopup extends MusicBeatSubstate {
	@:noCompletion var __popupTitle:String;
	@:noCompletion var __size:FlxPoint;

	@:noCompletion public var __onCreate:WindowPopup->Void;
	@:noCompletion public var __onUpdate:WindowPopup->Float->Void;

	public function new(?sizeX:Float = 420, ?sizeY:Float = 160, title:String, ?onCreate:WindowPopup->Void, ?onUpdate:WindowPopup->Float->Void):Void {
		__camera = (__camera ?? new FlxCamera());
		__camera.bgColor = 0;
		__camera.alpha = 0;
		__camera.zoom = 0.1;
		FlxG.cameras.add(__camera, false);

		__size = (__size ?? FlxPoint.get()).set(sizeX ?? 420, sizeY ?? 160);
		this.__popupTitle = title;

		this.__onCreate = onCreate;
		this.__onUpdate = onUpdate;
		super();
	}

	public var _windowBackground:UISliceSprite;
	public var _windowTitle:UIText;
	public var _closeBtn:UIObject;

	public var __camera:FlxCamera;

	@:dox(hide) @:noCompletion override function create():Void {
		cameras = [__camera];

		add(_windowBackground = new UISliceSprite(0, 0, Std.int(__size.x) ?? (FlxG.width - 200), Std.int(__size.y) ?? (FlxG.height - 100), "ui/window-bg"));
		_windowBackground.updateHitbox();
		_windowBackground.centerScreen();
		_windowBackground.scrollFactor.set();
		_windowBackground.cameras = cameras;

		add(_windowTitle = new UIText(0, 0, _windowBackground.bWidth, '- $__popupTitle -', 16));
		_windowTitle.setPosition(_windowBackground.x + (_windowBackground.bWidth - _windowTitle.width) / 2, (_windowBackground.y + _windowTitle.height) - 13);
		_windowTitle.alignment = CENTER;
		_windowTitle.cameras = cameras;

		// close button because YEAH!
		add(_closeBtn = new UIObject(_windowBackground.x + 25, _windowBackground.y, Paths.image('ui/close-button')));
		_closeBtn.y = _windowBackground.y + ((30 - _closeBtn.height) / 2);
		_closeBtn.x = (_windowBackground.x + _windowBackground.bWidth) - (_closeBtn.width + 10);
		_closeBtn.focusChange.add((duh:Bool, ?that:UIObject) -> that.color = duh ? FlxColor.GRAY : FlxColor.WHITE);
		_closeBtn.pressedCallback.add(closeAlt);
        _closeBtn.cameras = [__camera];

		if (__onCreate != null)
			__onCreate(this);

		FlxTween.tween(camera, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
		FlxTween.tween(camera, {zoom: 1}, 0.66, {ease: FlxEase.expoOut});
		super.create();
	}

	@:noCompletion final UGH_TWEEN_TIME:Float = .6;

	@:noCompletion function closeAlt(?v:UIObject):Void {
		if (v != null) v.available = false;

		FlxTween.tween(camera, {zoom: 0}, UGH_TWEEN_TIME + .06, {ease: FlxEase.expoOut});
		FlxTween.num(__camera.alpha, 0, UGH_TWEEN_TIME, {
			ease: FlxEase.expoOut,
			onComplete: _ -> close()
		}, __camera.set_alpha);
	}

	@:noCompletion var __inputBlock:Float = 0.1;

	@:dox(hide) @:noCompletion override function update(elapsed:Float):Void {
		super.update(elapsed);

		__inputBlock = Math.max(0, __inputBlock - elapsed);
		if (__inputBlock <= 0 && FlxG.keys.justPressed.ESCAPE) {
			closeAlt();
			return;
		}

		if (__onUpdate != null)
			__onUpdate(this, elapsed);
	}

	@:dox(hide) @:noCompletion override function destroy():Void {
		if (members != null)
			FlxDestroyUtil.destroyArray(members);
		if (__size != null)
			__size = FlxDestroyUtil.put(__size);
		if (__camera != null) {
			FlxTween.cancelTweensOf(__camera);
			FlxG.cameras.remove(__camera);
		}
		super.destroy();
	}
}
