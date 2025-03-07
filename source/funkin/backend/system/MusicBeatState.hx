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
	var _isCameraLoaded:Bool = false;

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
	 * All beats on a section.
	 */
	@:isVar
	var beatsOnSection(get, null):Float;
	@:dox(hide) inline function get_beatsOnSection():Float
	{
		// section beats, idk...
		final sectionBeats:Null<Float> = PlayState.SONG != null && PlayState.SONG.notes[curSection] != null ? PlayState.SONG.notes[curSection].sectionBeats : 4;
		return sectionBeats ?? 4;
	}

	/**
	 * The controls instance.
	 * @returns Controls Instance
	 */
	public var controls(get, never):Controls;
	@:dox(hide) inline function get_controls():Controls
		return Controls.instance;

	/**
	 * Returns the variables from the current state.
	 * @returns MusicBeatState variables.
	 */
	public inline static function getVariables():Map<String, Dynamic>
		return getState().variables;

	/**
	 * Variables
	 */
	public var variables(default,null):Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	* List of all stages.	
	*/
	@:allow(funkin.backend.base.BaseStage)
	var stages:Array<BaseStage> = [];

	@:dox(hide) override function create():Void
	{
		// init
		final skipNextTransOut:Bool = FlxTransitionableState.skipNextTransOut;
		_shaderGroup = null;
		_elapsed = 0;

		// global script stuff.
		GlobalScript.instance.executeClassScripts();
		super.create();
		GlobalScript.instance.callOnScripts('onCreatePost', []);

		// camera
		if (!_isCameraLoaded)
			setupCamera();

		// transition stuff (ignore this).
		if (!skipNextTransOut) openSubState(new FunkinFadeTransition(0.5, true));
		FlxTransitionableState.skipNextTransOut = false;
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
		_isCameraLoaded = true;
		return camera;
	}

	/**
	 * Keeps the elapsed time even after opening a substate.
	 */
	@:allow(funkin.backend.system.MusicBeatSubstate)
	@:dox(hide) static var _elapsed:Float = 0;
	inline function stageAccess(func:BaseStage->(Void)):Void
	{
		// very cool stage access function.
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				func(stage);
	}

	/**
	 *	Updates the selection with all needed beats.
	 */
	function updateSection():Void
	{
		// Gather todo steps.
		if (stepsToDo < 1) stepsToDo = Math.round(beatsOnSection * 4);

		// update da section.
		while (curStep >= stepsToDo)
		{
			curSection++;
			stepsToDo += Math.round(beatsOnSection * 4);
			sectionHit();
		}
	}

	/**
	 *	Rolls the current selection back.
	 */
	function rollbackSection():Void
	{
		if (curStep < 0) return;

		// saving the last section
		final lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;

		// looping thru all notes.
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(beatsOnSection * 4);
				if (stepsToDo > curStep) break;
				curSection++;
			}
		}

		// section hit, damn.
		if (curSection > lastSection) sectionHit();
	}

	/**
	 *	Updates the beat.
	 */
	function updateBeat():Void
	{
		// update beat
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	/**
	 *	Updates the current step.
	 */
	function updateCurStep():Void
	{
		// saving vars
		final lastChange:BPMChangeEvent = Conductor.getBPMFromSeconds(Conductor.songPosition);
		final curStepChange:Float = ((Conductor.songPosition - funkin.backend.utils.ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
	
		// update curstep.
		curDecStep = lastChange.stepTime + curStepChange;
		curStep = lastChange.stepTime + Math.floor(curStepChange);
	}

	/**
	 * Switches the state with a transition tween too.
	 *
	 * @param nextState The state you want to switch too.
	 */
	public static function switchState(nextState:EitherTwo<FlxState, MusicBeatState>):Void
	{
		// Make sure the next state doesn't equal null or the current state.
		nextState ??= FlxG.state;
		if (nextState == FlxG.state) return resetState();

		// Custom trans in.
		FlxTransitionableState.skipNextTransIn ? FlxG.switchState(nextState) : FunkinFadeTransition.startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	/**
	 *	Resets the state.
	 */
	public static function resetState():Void
	{
		// depending on `skipNextTransIn`. 
		FlxTransitionableState.skipNextTransIn ? FlxG.resetState() : FunkinFadeTransition.startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	/**
	 *	Gets the current state using a cast with the type of `MusicBeatState`.
	 */
	public inline static function getState():MusicBeatState
		return cast(FlxG.state, MusicBeatState);

	/**
	 *	The Stephit.
	 */
	public function stepHit():Void
	{
		// stage event stuff.
		stageAccess(function(stage:BaseStage)
		{
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		// beathit stuff
		if (curStep % 4 == 0) beatHit();
	}
	/**
	 *	The Beathit.
	 */
	public function beatHit():Void
	{
		// stage event stuff.
		stageAccess((stage:BaseStage) ->
		{
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});

		// softmoddin'
		GlobalScript.instance.setOnScripts('curBeat', curBeat); // DAWGG?????
		GlobalScript.instance.callOnScripts('onBeatHit', []);
	}

	/**
	 *	The section hit.
	 */
	public function sectionHit():Void
	{
		// stage event stuff.
		stageAccess(function(stage:BaseStage)
		{
			stage.curSection = curSection;
			stage.sectionHit();
		});

		// softmoddin'
		GlobalScript.instance.setOnScripts('curSection', curSection);
		GlobalScript.instance.callOnScripts('onSectionHit', []);
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		_elapsed += elapsed;

		// Fullscreen stuff.
		if (FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		// CurBeat stuff, sooo so cool!!!
		final oldStep:Int = curStep;
		updateCurStep();
		updateBeat();

		// Shaders
		if (_shaderGroup != null)
			for (shader in _shaderGroup)
				try
				{
					shader.update(elapsed);
				}
				catch (err:Dynamic)
					Logs.trace(err, RED);

		// Step Hit
		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();
			if (PlayState.SONG != null)
				oldStep < curStep ? updateSection() : rollbackSection();
		}

		// Softmoddin'
		stageAccess((stage:BaseStage) -> stage.update(elapsed));
		GlobalScript.instance.callOnScripts('onUpdate', [elapsed]); // gwa
		super.update(elapsed);
		GlobalScript.instance.callOnScripts('onUpdatePost', [elapsed]);
	}
	
	@:dox(hide) override function destroy():Void
		{
			// Softmoddin'
			#if LUA_ALLOWED
			for (luaScript in GlobalScript.instance.luaInstances)
			{
				luaScript.call('onDestroy', []);
				luaScript.stop();
			}
			GlobalScript.instance.luaInstances = [];
			FunkinLua.customFunctions.clear();
			#end
			
			#if HSCRIPT_ALLOWED
			for (haxeScript in GlobalScript.instance.hscriptInstances)
			{
				if (haxeScript != null)
				{
					final onDestory:Dynamic = haxeScript.get('onDestroy');
					if (onDestory != null && Reflect.isFunction(onDestory)) onDestory();
					haxeScript.destroy();
				}
			}
			GlobalScript.instance.hscriptInstances = [];
			#end
	
			super.destroy();
		}
}
