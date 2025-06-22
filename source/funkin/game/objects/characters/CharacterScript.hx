package funkin.game.objects.characters;

class CharacterScript extends FlxBasic
{ // we need to set the super instance of this to the Character.hx thingy okay!!! somehow...

	/**
	 * Character Instance.
	 */
	public var instance:Character = null;

	// func new
	public function new(?instance:Character):Void
	{
		// set the instance
		this.instance = instance;

		// super
		super();
	}

	/**
	 * All members of this `array` were added by `registerCharacterObject`.
	 */
	var characterMembers:Array<FlxObject> = [];

	/**
	 * Registering a object allows it to be tracked.
	 * 
	 * @param obj 
	 * @return FlxObject
	 */
	public function registerCharacterObject(obj:FlxObject):FlxObject
	{
		if (obj != null)
		{
			characterMembers.push(obj);
			return obj;
		}
		return null;
	}

	/**
	 * PlayState's current instance.
	 * Mainly used for interacting with `PlayState`.
	 */
	var game(get, never):PlayState;

	@:dox(hide) function get_game():PlayState
		return PlayState.instance;

	/**
	 * Once the player has fully been initialize#
	 *
	 * @returns Void
	 */
	public function post():Void
	{
	}

	/**
	 * Modified destroy function to destroy all script 
	 * members and remove itself.
	 * 
	 * @returns Void
	 */
	override public function destroy():Void
	{
		for (object in this.characterMembers)
			object.destroy();
		this.instance.characterScript = null;
		this.instance = null;
	}
}
