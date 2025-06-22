package chars;

import funkin.game.objects.characters.CharacterScript;

class Bf extends CharacterScript
{
	public function new() // new cannot access the instance class
	{
        super();
	}

	public function postNew() // postNew can access any fileds from the instance class
	{
		trace(instance.curCharacter); // dumbass
	}

	override public function destroy()
	{
		trace('yeah killing shitz');
		super.destroy();
	}
}
