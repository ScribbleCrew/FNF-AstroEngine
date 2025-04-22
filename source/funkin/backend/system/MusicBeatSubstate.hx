package funkin.backend.system;

import funkin.backend.Conductor;
import funkin.backend.utils.Controls;

// only get needed stuff
@:access(funkin.backend.system.MusicBeatState.getState)
@:access(funkin.backend.system.MusicBeatState.beatsOnSection)
@:access(funkin.backend.system.MusicBeatState._updateShaders)
 class MusicBeatSubstate extends flixel.FlxSubState
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
		this.scriptName = scriptName;
		this.scriptArgs = args;
		#end
		funkin.game.Main.stateName = scriptName != null ? scriptName : className.substring(className.lastIndexOf('.') + 1);// softmodded script support :D
		super();
	}
	override function create() {
		#if SOFTCODED_STATES
		// global script stuff.
		// gets the metadata of the current class.
		// not MusicBeatState, it's whatever is extending from it, since this is an abstract class.
		GlobalScript.instance.executeClassScripts(scriptName, scriptArgs, true);
		super.create();
		GlobalScript.instance.callOnScripts('onCreatePost', []); // gwa gwa lua
		GlobalScript.instance.callOnScripts('createPost', []);
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

		GlobalScript.instance.setOnScripts('curStep', curStep);//oops i forgor
		GlobalScript.instance.callOnScripts('onStepHit', []);
		GlobalScript.instance.callOnScripts('stepHit', []);
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
	public function beatHit():Void {/* Beat Hit */
			// softmoddin'
			GlobalScript.instance.setOnScripts('curBeat', curBeat); // DAWGG?????
			GlobalScript.instance.callOnScripts('onBeatHit', []);
			GlobalScript.instance.callOnScripts('beatHit', []);}


	/**
	 *	The section hit.
	 */
	public function sectionHit():Void {/* Section Hit */
	
			// softmoddin'
			GlobalScript.instance.setOnScripts('curSection', curSection);
			GlobalScript.instance.callOnScripts('onSectionHit', []);
			GlobalScript.instance.callOnScripts('sectionHit', []);}


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

		GlobalScript.instance.callOnScripts('onUpdate', [elapsed]); // gwa
		GlobalScript.instance.callOnScripts('update', [elapsed]); // gwa
		super.update(elapsed);
		GlobalScript.instance.callOnScripts('onUpdatePost', [elapsed]);
		GlobalScript.instance.callOnScripts('updatePost', [elapsed]);
	}

	override function close() {
		GlobalScript.instance.callOnScripts('onClose');
		trace('Pre: ${funkin.game.Main.stateName}');
		final className = Type.getClassName(Type.getClass(_parentState));
		funkin.game.Main.stateName = className.substring(className.lastIndexOf('.') + 1);
		super.close();
		trace('Post: ${funkin.game.Main.stateName}');
		GlobalScript.instance.callOnScripts('onClosePost');
	}

	/*
		@:dox(hide) override function destroy():Void
	{
		// Softmoddin'
		GlobalScript.instance.destroy();
		super.destroy();
	} */
}
