package objects;

import flixel.FlxSprite;
import funkin.game.objects.BGSprite;

class MallCrowd extends BGSprite
{
	public var heyTimer:Float = 0;
	public function new(x:Float = 0, y:Float = 0, ?sprite:String, ?idle:String, ?hey:String)
	{
		super(sprite ?? 'christmas/bottomBop', x, y, 0.9, 0.9, [idle ?? 'Bottom Level Boppers Idle']);
		animation.addByPrefix(hey ?? 'hey', 'Bottom Level Boppers HEY', 24, false);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(heyTimer > 0) {
			heyTimer -= elapsed;
			if(heyTimer <= 0) {
				dance(true);
				heyTimer = 0;
			}
		}
	}

	override public function dance(?forceplay:Bool = false)
	{
		if(heyTimer > 0) return;
		super.dance(forceplay);
	}
}