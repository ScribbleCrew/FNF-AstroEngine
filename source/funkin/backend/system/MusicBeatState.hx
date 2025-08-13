package funkin.backend.system;

import funkin.backend.Conductor.BPMChangeEvent as BPM_EVENT;
import flixel.addons.transition.FlxTransitionableState;

@:access(funkin.backend.ShaderBackend.update)
class MusicBeatState extends FlxState implements IBeat
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
		final sectionBeats:Null<Float> = PlayState.SONG != null
			&& PlayState.SONG.notes[curSection] != null ? PlayState.SONG.notes[curSection].sectionBeats : 4;
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
	public static function getVariables():Map<String, Dynamic>
		return getState().variables;

	/**
	 * Variables
	 */
	public var variables(default, null):Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * List of all stages.	
	 */
	@:allow(funkin.backend.base.BaseStage)
	var stages:Array<BaseStage> = [];

	#if SOFTCODED_STATES
	/**
	 * A pack of all scripts injected to this state
	 */
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
		super();

		#if SOFTCODED_STATES
		(stateScripts = new ScriptPack()).setParent(this);

		this.scriptName = scriptName;
		this.scriptArgs = args;
		#end
	}

	@:dox(hide) override function create():Void
	{
		// init
		final skipNextTransOut:Bool = FlxTransitionableState.skipNextTransOut;
		_shaderGroup = null;
		_elapsed = 0;

		final className = Type.getClassName(Type.getClass(FlxG.state));
		funkin.game.Main.stateName = className.substring(className.lastIndexOf('.') + 1);

		#if SOFTCODED_STATES
		// global script stuff.
		// gets the metadata of the current class.
		// not MusicBeatState, it's whatever is extending from it, since this is an abstract class.
		executeClassScripts(stateScripts, scriptName, scriptArgs);
		super.create();
		stateScripts.call('onCreatePost', []); // gwa gwa lua
		stateScripts.call('createPost', []);
		#end

		if (!_isCameraLoaded)
			setupCamera();

		funkin.backend.framerate.FramerateContainer.offset.set(0, 0);
		#if !SOFTCODED_STATES super.create(); #end

		// transition stuff (ignore this).
		if (!skipNextTransOut)
			openSubState(new FunkinFadeTransition(0.5, true));
		FlxTransitionableState.skipNextTransOut = false;
	}

	/**
	 * Extension map, contains all file extensions for allowed scripts.	
	 */
	static final extensions:Map<String, Array<String>> = new Map<String, Array<String>>();

	#if SOFTCODED_STATES
	/**
	 * Execute class scripts inside of mods/source.
	 * Used inside The BeatStates.
	 */
	public static function executeClassScripts(scripts:ScriptPack, ?customClass:String, ?scriptArgs:Array<Dynamic>, ?substate:Bool = false):Void
	{
		// Get the current state's class name.
		final currentClass:Class<Dynamic> = Type.getClass(FlxG.state);
		final _className:String = customClass != null ? customClass : Type.getClassName(currentClass);

		// Convert to lowercase for consistency
		final __className:String = _className.substring(_className.lastIndexOf('.') + 1).toLowerCase();

		// Loop through all mod folders containing scripts.
		for (folderName in Mods.directoriesWithFile(Paths.getSharedPath(), substate ? 'scripts/states/substates/' : 'scripts/states/'))
		{
			// Get all files inside the directory
			for (_fileName in FileSystem.readDirectory(folderName))
			{
				// Skip files without valid extensions
				if (!Script.checkScriptExtensions(_fileName))
					continue;

				// Skips disabled scripts.
				if (_fileName.startsWith("~"))
					continue;

				// Combines the folder path with the file name.
				final convertedScriptPath:String = folderName + _fileName;

				// Remove extension and convert to lowercase
				final convertedScriptName:String = _fileName.substr(0, _fileName.lastIndexOf('.')).toLowerCase();

				// Ensure the Global Script (global.hx, or anything that starts with global) runs no matter
				// the state, and scripts that are for specific states run when matching the state name.
				if (convertedScriptName != __className && !convertedScriptName.contains("global"))
					continue;

				// Execute Lua/HScript scripts if flag concurrent flag is enabled.
				#if LUA_ALLOWED
				if (Script.checkScriptExtensions(_fileName, "lua"))
					scripts.add(new FunkinLua(convertedScriptPath).execute(scriptArgs));
				#end
				#if HSCRIPT_ALLOWED
				if (Script.checkScriptExtensions(_fileName, "haxe"))
				{
					//	final _class =
					scripts.add(new HScript(null, convertedScriptPath).run(scriptArgs));
					//	_class.parent = (substate ? SUB : STATE); // yay enums
					//	_class.run(scriptArgs);
				};
				#end
			}
		}
	}
	#end

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

	/**
	 * Stage Access Tho...
	 * @param func The Function.	
	 */
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
		if (stepsToDo < 1)
			stepsToDo = Math.round(beatsOnSection * 4);

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
				stepsToDo += Math.round(beatsOnSection * 4);
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
	function _updateBeat():Void
	{
		// update beat
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	/**
	 *	Updates the current step.
	 */
	function _updateCurStep():Void
	{
		// saving vars
		final lastChange:BPM_EVENT = Conductor.getBPMFromSeconds(Conductor.songPosition);
		final curStepChange:Float = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;

		// update curstep.
		curDecStep = lastChange.stepTime + curStepChange;
		curStep = lastChange.stepTime + Math.floor(curStepChange);
	}

	/**
	 * Switches the state with a transition tween too.
	 *
	 * @param nextState The state you want to switch too.
	 * @param scriptName The script name you want to load.
	 */
	public static function switchState(?nextState:EitherTwo<FlxState, MusicBeatState>, ?scriptName:String, ?args:Array<Dynamic>):Void
	{
		// Make sure the next state doesn't equal null or the current state.
		nextState ??= new MusicBeatState(scriptName, args);
		if (nextState == FlxG.state)
			return resetState();

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
	 * Requires a lua object from the variables map.	
	 * @param tag The object's tag.
	 */
	public function getLuaObject(tag:String):FlxSprite
		return variables.get(tag);

	/**
	 *	Gets the current state using a cast with the type of `MusicBeatState`.
	 */
	inline static function getState():MusicBeatState
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

		// beat hit stuff
		if (curStep % 4 == 0)
			beatHit();

		stateScripts.set('curStep', curStep); // oops i forgor
		stateScripts.call('onStepHit', []);
		stateScripts.call('stepHit', []);
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
		stateScripts.set('curBeat', curBeat, LUA); // DAWGG?????
		stateScripts.call('onBeatHit', []);
		stateScripts.call('beatHit', []);
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
		stateScripts.set('curSection', curSection);
		stateScripts.call('onSectionHit', []);
		stateScripts.call('sectionHit', []);
	}

	@:dox(hide) function _updateShaders(elapsed:Float):Void
	{
		if (_shaderGroup != null)
			for (shader in _shaderGroup)
				try
				{
					shader.update(elapsed);
				}
				catch (err:Dynamic)
					Logs.trace(err, RED);
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		_elapsed += elapsed;

		// Fullscreen stuff.
		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		// CurBeat stuff, sooo so cool!!!
		final oldStep:Int = curStep;
		_updateCurStep();
		_updateBeat();

		// Shaders
		_updateShaders(elapsed);

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
		stateScripts.call('onUpdate', [elapsed]); // gwa
		stateScripts.call('update', [elapsed]); // gwa
		super.update(elapsed);
		stateScripts.call('onUpdatePost', [elapsed]);
		stateScripts.call('updatePost', [elapsed]);
	}

	@:dox(hide) override function destroy():Void
	{
		// Softmoddin'
		stateScripts.destroy();
		super.destroy();
	}
}
