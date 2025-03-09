package funkin.backend.system;

import flixel.FlxSubState;
import funkin.backend.Conductor;
import funkin.backend.utils.Controls;

@:access(funkin.backend.system.MusicBeatState)
abstract class MusicBeatSubstate extends FlxSubState
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
 
	function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(cast(FlxG.state, MusicBeatState).beatsOnSection * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = cast(FlxG.state, MusicBeatState).beatsOnSection;
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	function rollbackSection():Void
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
				stepsToDo += Math.round(cast(FlxG.state, MusicBeatState).beatsOnSection * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	/**
	 *	The Stephit.
	 */
	public function stepHit():Void
		if (curStep % 4 == 0) beatHit();

	/**
	 *	The Beathit.
	 */
	public function beatHit():Void {}

	/**
	 *	The section hit.
	 */
	public function sectionHit():Void {}

	@:dox(hide) override function update(elapsed:Float):Void
		{
			// keeps elapsed while in a substate.
			if (!persistentUpdate) MusicBeatState._elapsed += elapsed;
	
			final oldStep:Int = curStep;
	
			updateCurStep();
			updateBeat();
	
			if (oldStep != curStep)
			{
				if (curStep > 0) stepHit();
				if (PlayState.SONG != null) (oldStep < curStep) ? updateSection() : rollbackSection();
			}
	
			super.update(elapsed);
		}
}
