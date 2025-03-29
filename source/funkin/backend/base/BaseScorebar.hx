package funkin.backend.base;

import funkin.game.objects.scorebars.DefaultHUD;

class BaseScorebar extends FlxBasic
{
	private var game(get, never):PlayState;
	@:dox(hide) inline function get_game():PlayState
		return PlayState.instance;

	private var scoreUpdate(default, set):Void->Void;
	@:dox(hide) inline function set_scoreUpdate(erm:Void->Void):Void->Void
	{
		erm();
		return game.scoreUpdate = erm;
	}

	public function new():Void
	{
		if (this.game == null)
			destroy();
		else
		{
			FlxG.log.add('Scorebar Created');

			super();
			create();
			game.ui = this;
			scoreUpdate = updateScore;
			createPost();
			PlayState.instance.uiGroup.forEach((spr) -> spr.alpha = 0);
		}
	}

	public function create() {}
	public function createPost() {}
	public function updateScore() {}


	// modified add, remove and insert functions.
	function add(object:FlxBasic):Void
		game.uiGroup.add(untyped object);

	function remove(object:FlxBasic):Void
		game.uiGroup.remove(untyped object);

	function insert(position:Int, object:FlxBasic):Void
		game.uiGroup.insert(position, untyped object);
}
