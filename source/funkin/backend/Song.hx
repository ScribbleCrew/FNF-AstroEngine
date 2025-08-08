package funkin.backend;

import haxe.Json;
import lime.utils.Assets;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var offset:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var format:String;

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;

	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	@:optional var altAnim:Bool;
	@:optional var gfSection:Bool;
	@:optional var bpm:Float;
	@:optional var changeBPM:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var gameOverChar:String;
	public var gameOverSound:String;
	public var gameOverLoop:String;
	public var gameOverEnd:String;
	public var disableNoteRGB:Bool = false;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var format:String = 'astro_v${EngineData.VERSION}';

	public static final DEFAULT_CHART:SwagSong = {
		song: 'Test',
		notes: [],
		events: [],
		bpm: 150,
		needsVoices: true,
		speed: 1,
		offset: 0,
		player1: 'bf',
		player2: 'dad',
		gfVersion: 'gf',
		stage: 'stage',
		format: 'astro_v${EngineData.VERSION}'
	};

	public static function convert(songJson:Dynamic) // Convert old charts to psych_v1 format
	{
		if (songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			if (Reflect.hasField(songJson, 'player3'))
				Reflect.deleteField(songJson, 'player3');
		}

		if (songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while (i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if (note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else
						i++;
				}
			}
		}

		var sectionsData:Array<SwagSection> = songJson.notes;
		if (sectionsData == null)
			return;

		for (section in sectionsData)
		{
			var beats:Null<Float> = cast section.sectionBeats;
			if (beats == null || Math.isNaN(beats))
			{
				section.sectionBeats = 4;
				if (Reflect.hasField(section, 'lengthInSteps'))
					Reflect.deleteField(section, 'lengthInSteps');
			}

			for (note in section.sectionNotes)
			{
				var gottaHitNote:Bool = (note[1] < 4) ? section.mustHitSection : !section.mustHitSection;
				note[1] = (note[1] % 4) + (gottaHitNote ? 0 : 4);

				if (!Std.isOfType(note[3], String))
					note[3] = Note.defaultNoteTypes[note[3]]; // compatibility with Week 7 and 0.1-0.3 psych charts
			}
		}
	}

	public static var chartPath:String;
	public static var loadedSongName:String;

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		if (folder == null)
			folder = jsonInput;
		PlayState.SONG = getChart(jsonInput, folder);
		loadedSongName = folder;
		chartPath = _lastPath.replace('/', '\\');
		StageData.loadDirectory(PlayState.SONG);
		return PlayState.SONG;
	}

	@:dox(hide) static var _lastPath:String;

	@:noUsing public static function getChart(jsonInput:String, ?folder:String):SwagSong
	{
		folder??=jsonInput;

		final cuh:String = '${Paths.formatToSongPath(folder)}/${Paths.formatToSongPath(jsonInput)}';
		final fixedPath:String = AssetsPaths.JSON_REGEX.match(cuh) ? cuh : cuh + AssetsPaths.JSON_SUFFEX;
		_lastPath = fixedPath;
		final rawData:String = AssetsPaths.getContent('data/songs/$fixedPath');
		trace(fixedPath);
		return rawData != null ? parseJSON(rawData, jsonInput) : null;
	}

	@:noUsing public static function parseJSON(rawData:String, ?nameForError:String = null, ?convertTo:String = ''):SwagSong
	{
		final stupidHaxe = 'astro_v${EngineData.VERSION}';

		var songJson:SwagSong = cast tjson.TJSON.parse(rawData);
		if (Reflect.hasField(songJson, 'song'))
		{
			var subSong:SwagSong = Reflect.field(songJson, 'song');
			if (subSong != null && Type.typeof(subSong) == TObject)
				songJson = subSong;
		}

		if (convertTo == '')
			convertTo = stupidHaxe;

		if (convertTo != null && convertTo.length > 0)
		{
			var fmt:String = songJson.format;
			if (fmt == null)
				fmt = songJson.format = 'unknown';
			switch (convertTo)
			{
				case stupidHaxe:
					// psych support :3
					final fmt = fmt.toLowerCase();
					if (!fmt.startsWith('astro_v') && !fmt.startsWith('psych_v1')) // Convert to Psych 1.0 format
					{
						Logs.prefixedTrace('Converted chart $nameForError ($fmt) to astro_v${EngineData.VERSION}', 'Song Manager', ORANGE);
						songJson.format = 'astro_v${EngineData.VERSION}_convert';
						convert(songJson);
					}
			}
		}
		return songJson;
	}
}
