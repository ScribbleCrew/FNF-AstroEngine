package funkin.game.objects.characters;

class CharacterScript extends FlxBasic
{ // we need to set the super instance of this to the Character.hx thingy okay!!!

	/**
	 * Character Instance.
	 */
	public var instance:Character = null;

	/**
	 * Game Instance
	 */
	var game(get, never):PlayState;
	@:dox(hide) function get_game():PlayState
		return PlayState.instance;

	/**
	 * Once the player has fully been initialize
	 */
	public function post() {}

	override public function destroy():Void
	{
		this.instance.characterScript = null;
		this.instance = null;
	}
}
