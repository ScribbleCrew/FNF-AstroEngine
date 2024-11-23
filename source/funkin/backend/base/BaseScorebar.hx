package funkin.backend.base;

class BaseScorebar extends FlxBasic
{
	private var game(get, never):Dynamic;
	private var scoreUpdate(default, set):Void->Void;
	private var stageUpdate(default, set):Void->Void;
	private var defaultPos(get,never):FlxPoint;

	public function new()
	{
		if (this.game == null)
		{
			destroy();
		}
		else
		{
			FlxG.log.add('Scorebar Created');

			super();
			create();

			game.stageUpdate = update;
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

	// Gets And Sets Shit
	private inline function set_stageUpdate(erm:Void->Void)
	{
		game.stageUpdate = erm;
		erm();
		return erm;
	}

	private inline function set_scoreUpdate(erm:Void->Void)
	{
		game.scoreUpdate = erm;
		erm();
		return erm;
	}

	private inline function get_game():Dynamic
		return cast FlxG.state;

	private inline function get_defaultPos() 
		return game.healthBar.getPosition();

	// uhh owo?
	function add(object:FlxBasic)
		game.uiGroup.add(object);

	function remove(object:FlxBasic)
		game.uiGroup.remove(object);

	function insert(position:Int, object:FlxBasic)
		game.uiGroup.insert(position, object);
}
