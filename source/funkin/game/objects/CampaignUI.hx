package funkin.game.objects;

// i'll doc later -orbl
private enum abstract DaArrowType(String) to String from String
{
	final LEFT = "left";
	final RIGHT = "right";
	final LOCK = "lock";
}

// i hate my life
class CampaignUI extends FlxSprite
{
	public var shouldReact:Bool = false;
	public var isSelected:Bool = false;

	private var _defaultSize:FlxPoint = new FlxPoint();
	private var events:Map<String, Null<CampaignUI->Void>> = new Map<String, Null<CampaignUI->Void>>();

	public function new(?X:Float = 0, ?Y:Float = 0, TYPE:DaArrowType = LEFT):Void
	{
		super(X, Y);

		frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		if (TYPE != LOCK)
		{
			animation.addByPrefix('idle', 'arrow $TYPE');
			animation.addByPrefix('press', 'arrow push $TYPE');
		}
		else
			animation.addByPrefix('lock', TYPE);
		animation.play(animation.getByName('idle') != null ? 'idle' : 'lock');

		antialiasing = ClientPrefs.data.antialiasing;

		_defaultSize.set(this.scale.x, this.scale.y); // aww

		shouldReact = true;
	}

	/**
	 * Bindable event	
	 */
	public function bind(tag:String, func:CampaignUI->Void):Void // enum maybe??
		events.set(tag, func);

	private function get(tag:String):Null<CampaignUI->Void>
	{
		var GET_REQUEST = events.get(tag);
		if (GET_REQUEST != null)
			return GET_REQUEST;
		else
			return (void) -> {}; // fail safe, kinda...
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!shouldReact)
			return;

		if (FlxG.mouse.overlaps(this, camera))
		{
			if (FlxG.mouse.justPressed)
				get("clicked")(this);
			isSelected = true;
			FlxTween.tween(this.scale, {x: _defaultSize.x + .05, y: _defaultSize.y + .05}, .1, {ease: FlxEase.circOut});
		}
		else
		{
			isSelected = false;
			FlxTween.tween(this.scale, {x: _defaultSize.x, y: _defaultSize.y}, .1, {ease: FlxEase.circOut});
		}
	}
}
