package funkin.game.objects.mods;

import flixel.util.FlxSpriteUtil;
import flixel.graphics.FlxGraphic;

class ModButton extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var textOn:Alphabet;
	public var textOff:Alphabet;
	public var icon:FlxSprite;
	public var onClick:Void->Void = null;
	
	public var enabled(default, set):Bool = true;
	@:dox(hide) function set_enabled(newValue:Bool):Bool
	{
		enabled = newValue;
		setButtonVisibility(false);
		alpha = enabled ? 1 : 0.4;

		_needACheck = enabled;
		return newValue;
	}

	public function new(x:Float, y:Float, width:Int, height:Int, ?text:String = null, ?img:FlxGraphic = null, onClick:Void->Void = null, animWidth:Int = 0,
			animHeight:Int = 0)
	{
		super(x, y);

		bg = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite().makeGraphic(width, height, FlxColor.TRANSPARENT), 0, 0, width, height, 15, 15,15, 15, FlxColor.WHITE);
		bg.color = FlxColor.BLACK;
		add(bg);

		if (text != null)
		{
			textOn = new Alphabet(0, 0, "", false);
			textOn.setScale(0.6);
			textOn.text = text;
			textOn.alpha = 0.6;
			textOn.visible = false;
			centerOnBg(textOn);
			textOn.y -= 30;
			add(textOn);

			textOff = new Alphabet(0, 0, "", true);
			textOff.setScale(0.52);
			textOff.text = text;
			textOff.alpha = 0.6;
			centerOnBg(textOff);
			add(textOff);
		}
		else if (img != null)
		{
			icon = new FlxSprite();
			if (animWidth > 0 || animHeight > 0)
				icon.loadGraphic(img, true, animWidth, animHeight);
			else
				icon.loadGraphic(img);
			centerOnBg(icon);
			add(icon);
		}

		this.onClick = onClick;
		setButtonVisibility(false);
	}

	public var focusChangeCallback:Bool->Void = null;
	public var onFocus(default, set):Bool = false;

	@:noCompletion private inline function set_onFocus(newValue:Bool)
	{
		final lastFocus:Bool = onFocus;
		onFocus = newValue;
		if (onFocus != lastFocus && enabled)
			setButtonVisibility(onFocus);
		return newValue;
	}

	public var ignoreCheck:Bool = false;

	private var _needACheck:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!enabled)
		{
			onFocus = false;
			return;
		}

		if (!ignoreCheck && !Controls.instance.controllerMode && FlxG.mouse.justMoved && FlxG.mouse.visible)
			onFocus = FlxG.mouse.overlaps(this);

		if (onFocus && onClick != null && FlxG.mouse.justPressed)
			onClick();

		if (_needACheck)
		{
			_needACheck = false;
			if (!Controls.instance.controllerMode)
				setButtonVisibility(FlxG.mouse.overlaps(this));
		}
	}

	public function setButtonVisibility(focusVal:Bool)
	{
		alpha = 1;
		bg.color = focusVal ? FlxColor.WHITE : FlxColor.BLACK;
		bg.alpha = focusVal ? 0.8 : 0.6;

		var focusAlpha = focusVal ? 1 : 0.6;
		if (textOn != null && textOff != null)
		{
			textOn.alpha = textOff.alpha = focusAlpha;
			textOn.visible = focusVal;
			textOff.visible = !focusVal;
		}
		else if (icon != null)
		{
			icon.alpha = focusAlpha;
			icon.color = focusVal ? FlxColor.BLACK : FlxColor.WHITE;
		}

		if (!enabled)
			alpha = 0.4;
		if (focusChangeCallback != null)
			focusChangeCallback(focusVal);
	}

	public function centerOnBg(spr:FlxSprite)
	{
		spr.x = bg.width / 2 - spr.width / 2;
		spr.y = bg.height / 2 - spr.height / 2;
	}
}