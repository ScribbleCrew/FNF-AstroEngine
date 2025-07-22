package funkin.backend;

import funkin.backend.Song.SwagSong;
import funkin.game.states.PlayState;
import flixel.util.FlxSignal.FlxTypedSignal;
typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
	@:optional var stepCrochet:Float;
}

class Conductor
{
		/**
	 * FlxSignals
	 * idea: cne
	 */
	public static var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onBPMChange:FlxTypedSignal<Float->Void> = new FlxTypedSignal();


	public static var bpm(default, set):Float = 100;
	@:noCompletion inline static function set_bpm(BPMChange:Float):Float
		{
			crochet = calcCrochet(BPMChange);
			stepCrochet = crochet / 4;
			onBPMChange.dispatch(bpm);
			return bpm = BPMChange;
		}

	public static var crochet(get,default):Float; // beats in milliseconds
	@:noCompletion inline static function get_crochet():Float
		return calcCrochet(bpm);
	
	public static var stepCrochet(get,default):Float; // steps in milliseconds
	@:noCompletion inline static function get_stepCrochet():Float
		return crochet / 4;

	public static var songPosition:Float = 0;
	public static var offset:Float = 0;

	// public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = 0; // is calculated in create(), is safeFrames in milliseconds
	/**
	 * Current step
	 */
	public static var curStep:Int = 0;

	/**
	 * Current beat
	 */
	public static var curBeat:Int = 0;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static function init(){
		FlxG.signals.preUpdate.add(update);
	}
	static function update(){
		final oldStep:Int = curStep;
		final oldBeat:Int = curBeat;

		final lastChange:BPMChangeEvent = Conductor.getBPMFromSeconds(Conductor.songPosition);
		final curStepChange:Float = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;

		curStep = lastChange.stepTime + Math.floor(curStepChange); 
		curBeat = Math.floor(curStep/4);

		if (curStep > oldStep)
		{
			for(i in oldStep...curStep)
				onStepHit.dispatch(i+1);
		}

		if(curBeat > oldBeat)
			for(i in oldBeat...curBeat)
				onBeatHit.dispatch(i+1);
	}

	public static function judgeNote(arr:Array<Rating>, diff:Float = 0):Rating // die
	{
		var data:Array<Rating> = arr;
		for (i in 0...data.length - 1) // skips last window (Shit)
			if (diff <= data[i].hitWindow)
				return data[i];

		return data[data.length - 1];
	}

	public static function getCrotchetAtTime(time:Float):Float
		return getBPMFromSeconds(time).stepCrochet * 4;

	public static function getBPMFromSeconds(time:Float):BPMChangeEvent
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}
		for (i in 0...Conductor.bpmChangeMap.length)
			if (time >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];

		return lastChange;
	}

	public static function getBPMFromStep(step:Float):BPMChangeEvent
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}

		for (i in 0...Conductor.bpmChangeMap.length)
			if (Conductor.bpmChangeMap[i].stepTime <= step)
				lastChange = Conductor.bpmChangeMap[i];

		return lastChange;
	}

	public static function beatToSeconds(beat:Float):Float
	{
		var step = beat * 4;
		var lastChange = getBPMFromStep(step);
		return lastChange.songTime
			+ ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000; // TODO: make less shit and take BPM into account PROPERLY
	}

	public static function getStep(time:Float):Float
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getStepRounded(time:Float):Float
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getBeat(time:Float):Float
		return getStep(time) / 4;

	public static function getBeatRounded(time:Float):Int
		return Math.floor(getStepRounded(time) / 4);

	public static function mapBPMChanges(song:SwagSong) : Void
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM,
					stepCrochet: calcCrochet(curBPM) / 4
				};
				
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = Math.round(getSectionBeats(song, i) * 4);
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		Logs.prefixedTrace('Updated BPM map: $bpmChangeMap','Conductor', DARKCYAN);
	}

	static function getSectionBeats(song:SwagSong, section:Int):Null<Float>
	{
		var val:Null<Float> = null;
		if (song.notes[section] != null)
			val = song.notes[section].sectionBeats;
		return val != null ? val : 4;
	}

	inline public static function calcCrochet(bpm:Float):Float
		return (60 / bpm) * 1000;

}
