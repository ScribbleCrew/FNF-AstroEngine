package funkin.backend.system;

import flixel.FlxG;
import funkin.game.states.PlayState;
import funkin.backend.Conductor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import funkin.backend.utils.Controls;
import flixel.FlxCamera;
import flixel.FlxBasic;

abstract class MusicBeatState extends FlxState
{
	private var shaderGroup:Array<ShaderBackend>;
	
	private var customCameraLoaded:Bool = false;

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	public var controls(get, never):Controls;
	@:dox(hide) @:noCompletion private inline function get_controls():Controls
		return Controls.instance;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables():Map<String, Dynamic>
		return getState().variables;

	override function create():Void
	{
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		shaderGroup = null;
		super.create();

		if (!customCameraLoaded)
			setupCustomCamera();

		if (!skip)
			openSubState(new FunkinFadeTransition(0.5, true));

		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public function setupCustomCamera():CustomCamera
	{
		final camera = new CustomCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		customCameraLoaded = true;
		return camera;
	}

	public function addBehindObject(obj:FlxBasic, obj2:FlxBasic):FlxBasic
		return insert(members.indexOf(obj2), obj);

	public function addAheadObject(obj:FlxBasic, obj2:FlxBasic):FlxBasic
		return insert(members.indexOf(obj2) + 1, obj);

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float):Void
	{
		// everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (shaderGroup != null)
		{
			for (i in shaderGroup)
			{
				@:privateAccess
				i.update(elapsed);
			}
		}

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		stageAccess((stage:BaseStage) ->stage.update(elapsed));

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - funkin.backend.utils.ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState)
	{
		if (nextState == null)
			nextState = FlxG.state;
		if (nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if (FlxTransitionableState.skipNextTransIn)
			FlxG.switchState(nextState);
		else
			startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState()
	{
		if (FlxTransitionableState.skipNextTransIn)
			FlxG.resetState();
		else
			startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null)
	{
		if (nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new FunkinFadeTransition(0.6, false));
		if (nextState == FlxG.state)
			FunkinFadeTransition.finishCallback = function() FlxG.resetState();
		else
			FunkinFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():MusicBeatState
		return cast(FlxG.state, MusicBeatState);

	public function stepHit():Void
	{
		stageAccess(function(stage:BaseStage)
		{
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0)
			beatHit();
	}

	public var stages:Array<BaseStage> = [];

	public function beatHit():Void
	{
		// trace('Beat: ' + curBeat);
		stageAccess(function(stage:BaseStage)
		{
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		// trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stageAccess(function(stage:BaseStage)
		{
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stageAccess(func:BaseStage->(Void)):Void
	{
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection():Float
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
