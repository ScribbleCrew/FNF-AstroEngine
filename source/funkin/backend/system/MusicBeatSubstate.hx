package funkin.backend.system;

import funkin.backend.Conductor;
import funkin.backend.utils.Controls;

// only get needed stuff
@:access(funkin.backend.system.MusicBeatState.beatsOnSection)
@:access(funkin.backend.system.MusicBeatState._updateShaders)
abstract class MusicBeatSubstate extends flixel.FlxSubState
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
	 *	The step hit.
	 */
	public function stepHit():Void
		if (curStep % 4 == 0)
			beatHit();

	/**
	 *	The beat hit.
	 */
	public function beatHit():Void {/* Beat Hit */}

	/**
	 *	The section hit.
	 */
	public function sectionHit():Void {/* Section Hit */}

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

		super.update(elapsed);
	}
}
