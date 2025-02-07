package funkin.game.objects.stages.objects;

class DadBattleFog extends FlxSpriteGroup
{
	private static inline var offsetX:Int = 200;
	
	public function new():Void
	{
		super();
		
		alpha = 0;
		blend = ADD;

		var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(15, 22);
		smoke.active = true;
		smoke.antialiasing = ClientPrefs.data.antialiasing;
		add(smoke);

		var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(-15, -22);
		smoke.active = true;
		smoke.flipX = true;
		smoke.antialiasing = ClientPrefs.data.antialiasing;
		add(smoke);
	}
}