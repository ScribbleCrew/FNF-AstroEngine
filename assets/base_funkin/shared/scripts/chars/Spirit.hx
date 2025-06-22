package chars;

import funkin.game.objects.characters.CharacterScript;
import flixel.addons.effects.FlxTrail;

class Spirit extends CharacterScript
{
    // post() is after new()
    // post can access any fields from the instance class
	public function post() : Void 
	{
		game.addBehindDad(new FlxTrail(instance, null, 4, 24, 0.3, 0.069));
	}

    override public function update(elapsed):Void{
        trace(elapsed);
    }
}
