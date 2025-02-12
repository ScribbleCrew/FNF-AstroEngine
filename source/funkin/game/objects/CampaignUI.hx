package funkin.game.objects;

// i'll doc later -orbl
private enum abstract DaArrowType(String) to String from String
{
	final LEFT:String = "left";
	final RIGHT:String = "right";
	final LOCK:String = "lock";
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
			animation.addByPrefix('idle', TYPE);
		animation.play('idle');

		antialiasing = ClientPrefs.data.antialiasing;

		_defaultSize.set(this.scale.x, this.scale.y); // aww

		shouldReact = true;
	}

	/**
	 * Bind a event to a specific map value.
	 */
	public function bind(tag:String, func:CampaignUI->Void):Void // enum maybe??
		events.set(tag, func);

	/**
	 * Mainly used to GET functions from the map `events`...
	 */
	private function get(tag:String):Null<CampaignUI->Void>
	{
		final GET_REQUEST:CampaignUI->Void = events.get(tag);
		if (GET_REQUEST != null) return GET_REQUEST;
		return (void) -> {}; // fail safe, kinda...
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!shouldReact)
			return;

		if ((isSelected = FlxG.mouse.overlaps(this, camera)) && FlxG.mouse.justPressed)
		{
			FlxTween.tween(this, {"scale.x": this.scale.x * 0.85, "scale.y": this.scale.y * 0.85}, 0.2, {type: BACKWARD, ease: FlxEase.cubeOut});
			//if(animation.getByName('press') != null) animation.play('press');
			get("clicked")(this);

			new FlxTimer().start(.5, (_) -> {scale.set(_defaultSize.x, _defaultSize.y); animation.play('idle');});
		}
	}
}
