package objects;

import flixel.FlxSprite;
import funkin.game.objects.BGSprite;

class MallCrowd extends BGSprite
{
	public var heyTimer:Float = 0;
	public function new(x:Float = 0, y:Float = 0, ?sprite:String = 'christmas/bottomBop', ?idle:String = 'Bottom Level Boppers Idle', ?hey:String = 'Bottom Level Boppers HEY')
	{
		super('christmas/bottomBop', x, y, 0.9, 0.9, ['Bottom Level Boppers Idle']);
		animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
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
		//if(this.idleAnim != null) {
		//	animation.play(this.idleAnim, forceplay);
		//}
	}
}