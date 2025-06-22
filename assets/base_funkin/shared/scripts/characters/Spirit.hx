package character;

import funkin.game.objects.characters.CharacterScript;
import flixel.addons.effects.FlxTrail;

class Spirit extends CharacterScript
{
	var trail:FlxTrail = null;

	override function post():Void
	{
		trail = new FlxTrail(instance, null, 4, 24, 0.3, 0.069);
		game.addBehindDad(registerCharacterObject(trail));
	}

	override function update(elpased:Float)
	{
		if (trail != null && instance != null)
			trail.visible = instance.visible;
	}
}
