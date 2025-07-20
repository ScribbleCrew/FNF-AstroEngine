package funkin.backend.system;

import funkin.backend.Conductor;
import funkin.backend.utils.Controls;

// only get needed stuff
@:access(funkin.backend.system.MusicBeatState.getState)
@:access(funkin.backend.system.MusicBeatState.beatsOnSection)
@:access(funkin.backend.system.MusicBeatState._updateShaders)
class MusicBeatSubstate extends flixel.FlxSubState implements IBeat
{
	/**
	 * The current section, expressed as an int.	
	 */
	var curSection:Int = 0;

	/**
	 * The todo steps.
	 */
	var stepsToDo:Int = 0;

	/**
	 * The last beat.
	 */
	var lastBeat:Int = 0;

	/**
	 * The last step number.
	 */
	var lastStep:Int = 0;

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
	 *	Updates the selection with all needed beats.
	 */
	function updateSection():Void
	{
		// Gather todo steps.
		if (stepsToDo < 1)
			stepsToDo = Math.round(MusicBeatState.getState().beatsOnSection * 4);

		// update da section.
		while (curStep >= stepsToDo)
		{
			curSection++;
			stepsToDo += Math.round(MusicBeatState.getState().beatsOnSection * 4);
			sectionHit();
		}
	}

	#if SOFTCODED_STATES
	var stateScripts:ScriptPack;
	
	/**
	 * Softcoded state script name.
	 */
	var scriptName:String = null;

	/**
	 * Softcoded state script args.	
	 */
	var scriptArgs = null;
	#end

	public function new(?scriptName:String, ?args:Array<Dynamic>):Void
	{
		final className = Type.getClassName(Type.getClass(FlxG.state));
		#if SOFTCODED_STATES
		(stateScripts = new ScriptPack()).setParent(this);
		this.scriptName = scriptName;
		this.scriptArgs = args;
		#else
			if(scriptName != null || args != null)
				trace('softcoded states isn\'t allowed');
		#end
		funkin.game.Main.stateName = scriptName != null ? scriptName : className.substring(className.lastIndexOf('.') + 1); // softmodded script support :D
		super();
	}

	@:dox(hide) override function create():Void
	{
		#if SOFTCODED_STATES
		// global script stuff.
		// gets the metadata of the current class.
		// not MusicBeatState, it's whatever is extending from it, since this is an abstract class.
		MusicBeatState.executeClassScripts(stateScripts, scriptName, scriptArgs, true);
		super.create();
		stateScripts.call('onCreatePost', []); // gwa gwa lua
		stateScripts.call('createPost', []);
		#end
	}

	/**
	 *	Rolls the current selection back.
	 */
	function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		// saving the last section
		final lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;

		// looping thru all notes.
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(MusicBeatState.getState().beatsOnSection * 4);
				if (stepsToDo > curStep)
					break;
				curSection++;
			}
		}

		// section hit, damn.
		if (curSection > lastSection)
			sectionHit();

		stateScripts.set('curStep', curStep); // oops i forgor
		stateScripts.call('onStepHit', []);
		stateScripts.call('stepHit', []);
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
		final curStepChange:Float = ((Conductor.songPosition - funkin.backend.utils.ClientPrefs.data.noteOffset)
			- lastChange.songTime) / lastChange.stepCrochet;

		// update curstep.
		curDecStep = lastChange.stepTime + curStepChange;
		curStep = lastChange.stepTime + Math.floor(curStepChange);
	}

	/**
	 *	The step hit.
	 */
	public function stepHit():Void
		if (curStep % 4 == 0)
			beatHit();

	/**
	 *	The beat hit.
	 */
	public function beatHit():Void
	{/* Beat Hit */
		// softmoddin'
		stateScripts.set('curBeat', curBeat, LUA); // DAWGG?????
		stateScripts.call('onBeatHit', []);
		stateScripts.call('beatHit', []);
	}

	/**
	 *	The section hit.
	 */
	public function sectionHit():Void
	{/* Section Hit */
		// softmoddin'
		stateScripts.set('curSection', curSection);
		stateScripts.call('onSectionHit', []);
		stateScripts.call('sectionHit', []);
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		if (!persistentUpdate)
		{
			// keeps elapsed while in a substate.
			MusicBeatState._elapsed += elapsed;

			// update shaders while in an substate.
			MusicBeatState.getState()._updateShaders(elapsed);
		}

		final oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();
			if (PlayState.SONG != null)
				(oldStep < curStep)
			?updateSection
			() : rollbackSection
			();
		}

		stateScripts.call('onUpdate', [elapsed]); // gwa
		stateScripts.call('update', [elapsed]); // gwa
		super.update(elapsed);
		stateScripts.call('onUpdatePost', [elapsed]);
		stateScripts.call('updatePost', [elapsed]);
	}

	@:dox(hide) override function close():Void
	{
		stateScripts.call('onClose');
		final className = Type.getClassName(Type.getClass(_parentState));
		funkin.game.Main.stateName = className.substring(className.lastIndexOf('.') + 1);
		stateScripts.call('onClosePost');

		super.close();
	}

	override function destroy():Void
	{
		// softmodding
		stateScripts.call('onDestroy');
		stateScripts.call('destroy');
		stateScripts.destroy();

		super.destroy();
	}
}
