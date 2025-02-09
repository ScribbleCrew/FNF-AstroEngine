package funkin.backend.base;

import funkin.game.objects.scorebars.DefaultHUD;

class BaseScorebar extends FlxBasic
{
	private var game(get, never):Dynamic;

	private var scoreUpdate(default, set):Void->Void;
	@:noCompletion private inline function set_scoreUpdate(erm:Void->Void):Void->Void
		{
			game.scoreUpdate = erm;
			erm();
			return erm;
		}

	private var defaultPos(get,never):FlxPoint;
	@:noCompletion private inline function get_defaultPos():FlxPoint
		return game.baseUI.healthBar.getPosition();

	public function new()
	{
		if (this.game == null)
			destroy();
		else
		{
			FlxG.log.add('Scorebar Created');
			
			super();
			game.baseUI = new DefaultHUD();
			create();

			game.ui = this;
			scoreUpdate = updateScore;

			PlayState.instance.uiGroup.forEach((spr) -> spr.alpha = 0);
		}
	}

	public function create()
	{
	}

	public function updateScore()
	{
	}

	private inline function get_game():Dynamic
		return cast FlxG.state;

	// uhh owo?
	function add(object:FlxBasic) : Void
		game.uiGroup.add(object);

	function remove(object:FlxBasic) : Void
		game.uiGroup.remove(object);

	function insert(position:Int, object:FlxBasic) : Void
		game.uiGroup.insert(position, object);
}
