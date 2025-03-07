package funkin.backend.system;

import flixel.FlxG;
import funkin.game.states.PlayState;
import funkin.backend.Conductor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import funkin.backend.utils.Controls;

@:access(funkin.backend.ShaderBackend.update)
abstract class MusicBeatState extends FlxState
{
	/**
	 * Group which contains all shader instances which
	 * extend from `ShaderBackend`.
	 */
	var _shaderGroup:Array<ShaderBackend> = null;

	/**
	 * Is the camera loaded.
	 */
	var _cameraLoaded:Bool = false;

	/**
	 * The current section, expressed as an int.	
	 */
	var curSection:Int = 0;

	/**
	 * The todo steps.
	 */
	var stepsToDo:Int = 0;

	/**
	 * The current step, expressed as an int.	
	 */
	var curStep:Int = 0;

	/**
	 * The current dec(?) step, expressed as an int.	
	 */
	var curDecStep:Float = 0;

	/**
	 * The current beat, expressed as an int.	
	 */
	var curBeat:Int = 0;

	/**
	 * The current dec(?) beat, expressed as an int.	
	 */
	var curDecBeat:Float = 0;

	/**
	 * The controls instance.
	 * @returns Controls Instance
	 */
	public var controls(get, never):Controls;

	@:dox(hide) inline function get_controls():Controls
		return Controls.instance;

	/**
	 * The controls instance.
	 * @returns Controls instance.
	 */
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * Returns the variables from the current state.
	 * @returns MusicBeatState variables.
	 */
	public inline static function getVariables():Map<String, Dynamic>
		return getState().variables;

	override function create():Void
	{
		final skipNextTransOut:Bool = FlxTransitionableState.skipNextTransOut;
		_shaderGroup = null;

		super.create();

		setupClassScript();

		if (!_cameraLoaded)
			setupCamera();

		if (!skipNextTransOut)
			openSubState(new FunkinFadeTransition(0.5, true));

		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}
	var hscriptInstance:HScript = null;
	function setupClassScript():Void
	{
		final className = Type.getClassName(Type.getClass(this));
		final classScript:String = Paths.modFolders('source/${className.substring(className.lastIndexOf('.') + 1)}.hx');
		if (FileSystem.exists(classScript))
		{
			hscriptInstance = new HScript(null, classScript);
			GlobalScript.instance.callIndividualHaxe(hscriptInstance, 'onCreate');
		}
	}

	/**
	 * Sets up the custom camera.
	 * @returns The Custom Camera
	 */
	public function setupCamera():CustomCamera
	{
		final camera = new CustomCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_cameraLoaded = true;
		return camera;
	}

	/**
	 * Sets up the custom camera.
	 * @returns The Custom Camera
	 */
	public static var timePassedOnState:Float = 0;

	override function update(elapsed:Float):Void
	{
		// everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (_shaderGroup != null)
			for (shader in _shaderGroup)
				try
				{
					shader.update(elapsed);
				}
				catch (err:Dynamic)
					Logs.trace(err, RED);

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
		}

		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		stageAccess((stage:BaseStage) -> stage.update(elapsed));
		GlobalScript.instance.callIndividualHaxe(hscriptInstance, 'onUpdate',[elapsed]);//gwa
		super.update(elapsed);
		GlobalScript.instance.callIndividualHaxe(hscriptInstance, 'onUpdatePost',[elapsed]);

	}

	function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(beatsOnSection * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = beatsOnSection;
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		final lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(beatsOnSection * 4);
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

	public inline static function getState():MusicBeatState
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

	/**
	 * All beats on a section.
	 */
	var beatsOnSection(get, null):Float;

	@:dox(hide) @:noCompletion function get_beatsOnSection():Float
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
