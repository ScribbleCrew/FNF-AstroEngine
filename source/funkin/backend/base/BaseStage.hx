package funkin.backend.base;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class BaseStage extends FlxBasic
{
	private var game(get, never):Dynamic;
	private var playstate(default, never):Dynamic = PlayState;

	public var onPlayState:Bool = true;

	public var paused(get, never):Bool;
	public var songName(get, never):String;
	public var isStoryMode(get, never):Bool;
	public var seenCutscene(get, never):Bool;
	public var inCutscene(get, set):Bool;
	public var canPause(get, set):Bool;
	public var members(get, never):Dynamic;

	public var boyfriend(get, never):Character;
	public var dad(get, never):Character;
	public var gf(get, never):Character;
	public var boyfriendGroup(get, never):FlxSpriteGroup;
	public var dadGroup(get, never):FlxSpriteGroup;
	public var gfGroup(get, never):FlxSpriteGroup;

	public var camGame(get, never):FlxCamera;
	public var camHUD(get, never):FlxCamera;
	public var camOther(get, never):FlxCamera;

	public var defaultCamZoom(get, set):Float;
	public var camFollow(get, never):FlxObject;

	public var startCallback(get, set):Void->Void;
	public var endCallback(get, set):Void->Void;

	public function new()
	{
		if (this.game == null)
		{
			FlxG.log.error('Invalid state for the stage added!');
			destroy();
		}
		else
		{
			this.game.stages.push(this);
			FlxG.log.add('Stage Created');
			super();
			create();
		}
	}

	// main callbacks
	public function create()
	{
	}

	public function createPost()
	{
	}

	// public function update(elapsed:Float) {}
	public function countdownTick(count:Countdown, num:Int)
	{
	}

	public function startSong()
	{
	}

	// FNF steps, beats and sections
	public var curBeat:Int = 0;
	public var curDecBeat:Float = 0;
	public var curStep:Int = 0;
	public var curDecStep:Float = 0;
	public var curSection:Int = 0;

	public function beatHit()
	{
	}

	public function stepHit()
	{
	}

	public function sectionHit()
	{
	}

	// Substate close/open, for pausing Tweens/Timers
	public function closeSubState()
	{
	}

	public function openSubState(SubState:FlxSubState)
	{
	}

	// Events
	public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
	}

	public function eventPushed(event:EventNote)
	{
	}

	public function eventPushedUnique(event:EventNote)
	{
	}

	// Note Hit/Miss
	public function goodNoteHit(note:Note)
	{
	}

	public function opponentNoteHit(note:Note)
	{
	}

	public function noteMiss(note:Note)
	{
	}

	public function noteMissPress(direction:Int)
	{
	}

	// Things to replace FlxGroup stuff and inject sprites directly into the state
	function add(object:FlxBasic)
		return FlxG.state.add(object);

	function remove(object:FlxBasic, splice:Bool = false)
		return FlxG.state.remove(object, splice);

	function insert(position:Int, object:FlxBasic)
		return FlxG.state.insert(position, object);

	public function addBehindGF(obj:FlxBasic)
		insert(members.indexOf(game.gfGroup), obj);

	public function addBehindBF(obj:FlxBasic)
		insert(members.indexOf(game.boyfriendGroup), obj);

	public function addBehindDad(obj:FlxBasic)
		insert(members.indexOf(game.dadGroup), obj);

	public function setDefaultGF(name:String) // Fix for the Chart Editor on Base Game stages
	{
		var gfVersion:String = playstate.SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = name;
			playstate.SONG.gfVersion = gfVersion;
		}
	}

	public function getStageObject(name:String) // Objects can only be accessed *after* create(), use createPost() if you want to mess with them on init
		return game.variables.get(name);

	// start/end callback functions
	public function setStartCallback(myfn:Void->Void)
	{
		if (!onPlayState)
			return;
		PlayState.instance.startCallback = myfn;
	}

	public function setEndCallback(myfn:Void->Void)
	{
		if (!onPlayState)
			return;
		PlayState.instance.endCallback = myfn;
	}

	// start/end callback functions
	inline private function get_startCallback()
		return game.startCallback;

	inline public function set_startCallback(func:Void->Void)
	{
		game.startCallback = func;
		return func;
	}

	inline private function get_endCallback()
		return game.endCallback;

	inline private function set_endCallback(func:Void->Void)
	{
		game.endCallback = func;
		return func;
	}

	// overrides
	function startCountdown()
		if (onPlayState)
			return game.startCountdown();
		else
			return false;

	function endSong()
		if (onPlayState)
			return game.endSong();
		else
			return false;

	function moveCameraSection()
		if (onPlayState)
			moveCameraSection();

	function moveCamera(isDad:Bool)
		if (onPlayState)
			PlayState.instance.moveCamera(isDad);

	@:noCompletion inline private function get_paused():Bool
		return game.paused;

	@:noCompletion inline private function get_songName():String
		return playstate.SONG.song.toLowerCase();

	@:noCompletion inline private function get_isStoryMode():Bool
		return playstate.isStoryMode;

	@:noCompletion inline private function get_seenCutscene():Bool
		return playstate.seenCutscene;

	@:noCompletion inline private function get_inCutscene():Bool
		return game.inCutscene;

	@:noCompletion inline private function set_inCutscene(value:Bool):Bool
		return game.inCutscene = value;

	@:noCompletion inline private function get_canPause():Bool
		return game.canPause;

	@:noCompletion inline private function set_canPause(value:Bool):Bool
		return game.canPause = value;

	@:noCompletion inline private function get_members():Dynamic
		return game.members;

	@:noCompletion inline private function get_game():Dynamic
		return cast FlxG.state;

	@:noCompletion inline private function get_boyfriend():Character
		return game.boyfriend;

	@:noCompletion inline private function get_dad():Character
		return game.dad;

	@:noCompletion inline private function get_gf():Character
		return game.gf;

	@:noCompletion inline private function get_boyfriendGroup():FlxSpriteGroup
		return game.boyfriendGroup;

	@:noCompletion inline private function get_dadGroup():FlxSpriteGroup
		return game.dadGroup;

	@:noCompletion inline private function get_gfGroup():FlxSpriteGroup
		return game.gfGroup;

	@:noCompletion inline private function get_camGame():FlxCamera
		return game.camGame;

	@:noCompletion inline private function get_camHUD():FlxCamera
		return game.camHUD;

	@:noCompletion inline private function get_camOther():FlxCamera
		return game.camOther;

	@:noCompletion inline private function get_defaultCamZoom():Float
		return game.defaultCamZoom;

	@:noCompletion inline private function set_defaultCamZoom(value:Float):Float
		return game.defaultCamZoom = value;

	@:noCompletion inline private function get_camFollow():FlxObject
		return game.camFollow;
}
