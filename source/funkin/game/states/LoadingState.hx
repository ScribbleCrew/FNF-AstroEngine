package funkin.game.states;

import lime.app.Future;
import sys.thread.FixedThreadPool;
import funkin.backend.system.initialization.Logs;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;
import lime.utils.Assets;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import haxe.ds.StringMap;

#if cpp
@:headerCode('
#include <iostream>
#include <thread>
')
#end
class LoadingState extends MusicBeatState
{
	/**
	* The amount of loaded files.
	*/
	public static var loaded:Int = 0;


	public static var loadMax:Int = 0;

	static var originalBitmapKeys:StringMap<String> = new StringMap();
	static var requestedBitmaps:Map<String, BitmapData> = [];
	
	static var mutex:Mutex;
	static var threadPool:FixedThreadPool = null;

	/**
	 * The target state.	
	 */
	var target:FlxState = null;

	/**
	 * Stop the music.	
	 */
	var stopMusic:Bool = false;

	public function new(target:FlxState, stopMusic:Bool):Void
	{
		this.target = target;
		this.stopMusic = stopMusic;

		super();
	}

	/**
	 * Load and switch state.
	 *
	 * @param target FlxState
	 * @param stopMusic boolean
	 * @param intrusive boolean
	 */
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false, intrusive:Bool = true)
		MusicBeatState.switchState(getNextState(target, stopMusic, intrusive));

	/**
	 * Don't update, i guess...	
	 */
	var dontUpdate:Bool = false;

	var bar:FlxSprite;
	var barWidth:Int = 0;
	var intendedPercent:Float = 0;
	var curPercent:Float = 0;
	var canChangeState:Bool = true;

	#if ASTRO_WATERMARKS
	var logo:FlxSprite;
	var timePassed:Float;
	#else
	var funkay:FlxSprite;
	#end

	var stateChangeDelay:Float = 0;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite(0, 660).makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width - 300, 25);
		bg.updateHitbox();
		bg.screenCenter(X);
		add(bg);

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('astro'));
		logo.scale.set(0.25, 0.25);
		logo.updateHitbox();
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.x = FlxG.width - logo.width - 10;
		add(logo);

		bar = new FlxSprite(bg.x + 5, bg.y + 5).makeGraphic(1, 1, FlxColor.WHITE);
		bar.scale.set(0, 15);
		bar.updateHitbox();
		add(bar);
		barWidth = Std.int(bg.width - 10);

		persistentUpdate = true;

		super.create();

		if (stateChangeDelay <= 0 && checkLoaded())
		{
			dontUpdate = true;
			onLoad();
		}

		#if HSCRIPT_ALLOWED
		// grabs all class scripts running for LoadingState.
		for (i in GlobalScript.instance.hscriptInstances.get('LoadingState'))
		{ // HAHAHAHAHAHAH
			i.variables.set('getLoaded', () -> return loaded);
			i.variables.set('getLoadMax', () -> return loadMax);
			// i.set('barBack', barBack);
			// i.set('bar', bar);
		}
		#end
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (dontUpdate)
			return;

		if (!transitioning)
		{
			if (!finishedLoading && checkLoaded())
			{
				if (stateChangeDelay <= 0)
				{
					transitioning = true;
					onLoad();
					return;
				}
				else
					stateChangeDelay = Math.max(0, stateChangeDelay - elapsed);
			}
			intendedPercent = loaded / loadMax;
		}

		if (curPercent != intendedPercent)
		{
			if (Math.abs(curPercent - intendedPercent) < 0.001)
				curPercent = intendedPercent;
			else
				curPercent = FlxMath.lerp(intendedPercent, curPercent, Math.exp(-elapsed * 15));

			bar.scale.x = barWidth * curPercent;
			bar.updateHitbox();
		}
	}

	var finishedLoading:Bool = false;

	function onLoad()
	{
		_loaded();

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.camera.visible = false;
		MusicBeatState.switchState(target);
		transitioning = true;
		finishedLoading = true;
	}

	static function _loaded()
	{
		loaded = 0;
		loadMax = 0;
		initialThreadCompleted = true;
		isIntrusive = false;

		FlxTransitionableState.skipNextTransIn = true;
		if (threadPool != null)
			threadPool.shutdown(); // kill all workers safely
		threadPool = null;
		mutex = null;
	}

	public static function checkLoaded():Bool
	{
		for (key => bitmap in requestedBitmaps)
		{
			if (bitmap != null && Paths.cacheBitmap(originalBitmapKeys.get(key), bitmap) != null)
				Logs.trace('Successfully cached: image/$key', GREEN); // trace('finished preloading image $key');
			else
				Logs.trace('Failed to cache: image/$key', RED);
		}
		requestedBitmaps.clear();
		originalBitmapKeys.clear();

		return (loaded >= loadMax && initialThreadCompleted);
	}

	public static function loadNextDirectory():Void
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if (weekDir != null && weekDir.length > 0 && weekDir != '')
			directory = weekDir;

		Paths.currentLevel = directory;
		Logs.prefixedTrace('Setting asset folder to $directory', 'Loading State', DARKCYAN);
	}

	static var isIntrusive:Bool = false;

	static function getNextState(target:FlxState, stopMusic = false, intrusive:Bool = true):FlxState
	{
		LoadingState.isIntrusive = intrusive;
		_startPool();
		loadNextDirectory();

		if (intrusive)
			return new LoadingState(target, stopMusic);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		while (true)
		{
			if (checkLoaded())
			{
				_loaded();
				break;
			}
			else
				Sys.sleep(0.001);
		}
		return target;
	}

	/**
	* Map of assets to preload.	
	*/
	static var AssetsToPrepare:Map<String, Array<String>> = ["images" => [], "sounds" => [], "music" => [], "songs" => []];

	/**
	*	
	*/
	public static function prepare(images:Array<String> = null, sounds:Array<String> = null, music:Array<String> = null):Void
	{
		if (images != null) AssetsToPrepare.get('images').concat(images); // good?
		if (sounds != null) AssetsToPrepare.get('sounds').concat(sounds);
		if (music != null) AssetsToPrepare.get('music').concat(music);
	}

	static var initialThreadCompleted:Bool = true;
	static var dontPreloadDefaultVoices:Bool = false;

	static function _startPool() : Void
		threadPool = new FixedThreadPool(#if MULTITHREADED_LOADING #if cpp OsAPI.cpuThreads #else 8 #end #else 1 #end);

	public static function prepareToSong()
	{
		_startPool();

		AssetsToPrepare.set('images', []);
		AssetsToPrepare.set('sounds', []);
		AssetsToPrepare.set('music', []);
		AssetsToPrepare.set('songs', []);

		initialThreadCompleted = false;
		var threadsCompleted:Int = 0;
		var threadsMax:Int = 0;
		function completedThread()
		{
			threadsCompleted++;
			if (threadsCompleted == threadsMax)
			{
				clearInvalids();
				startThreads();
				initialThreadCompleted = true;
			}
		}

		var song:SwagSong = PlayState.SONG;
		var folder:String = Paths.formatToSongPath(Song.loadedSongName);
		new Future<Bool>(() ->
		{
			// LOAD NOTE IMAGE
			var noteSkin:String = Note.defaultNoteSkin;
			if (PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
				noteSkin = PlayState.SONG.arrowSkin;

			var customSkin:String = noteSkin + Note.getNoteSkinPostfix();
			if (Paths.fileExists('images/$customSkin.png', IMAGE))
				noteSkin = customSkin;
			AssetsToPrepare.get('images').push(noteSkin);
			//

			// LOAD NOTE SPLASH IMAGE
			var noteSplash:String = NoteSplash.defaultNoteSplash;
			if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
				noteSplash = PlayState.SONG.splashSkin;
			else
				noteSplash += NoteSplash.getSplashSkinPostfix();
			AssetsToPrepare.get('images').push(noteSplash);

			try
			{
				var path:String = Paths.json('$folder/preload');
				var json:Dynamic = null;

				#if MODS_ALLOWED
				final moddyFile:String = Paths.modsJson('$folder/preload');
				json = tjson.TJSON.parse(File.getContent(FileSystem.exists(moddyFile) ? moddyFile : path));
				#else
				json = tjson.TJSON.parse(Assets.getText(path));
				#end

				if (json != null)
				{
					var imgs:Array<String> = [];
					var snds:Array<String> = [];
					var mscs:Array<String> = [];
					for (asset in Reflect.fields(json))
					{
						var filters:Int = Reflect.field(json, asset);
						var asset:String = asset.trim();

						if (filters < 0 || StageData.validateVisibility(filters))
						{
							if (asset.startsWith('images/'))
								imgs.push(asset.substr('images/'.length));
							else if (asset.startsWith('sounds/'))
								snds.push(asset.substr('sounds/'.length));
							else if (asset.startsWith('music/'))
								mscs.push(asset.substr('music/'.length));
						}
					}
					prepare(imgs, snds, mscs);
				}
			}
			catch (e:Dynamic)
			{
			}
			return true;
		}, isIntrusive).then((_) -> new Future<Bool>(() ->
			{
				if (song.stage == null || song.stage.length < 1)
					song.stage = StageData.vanillaSongStage(folder);

				var stageData:funkin.backend.data.StageData.StageFile = StageData.getStageFile(song.stage);
				if (stageData != null)
				{
					var imgs:Array<String> = [];
					var snds:Array<String> = [];
					var mscs:Array<String> = [];
					if (stageData.preload != null)
					{
						for (asset in Reflect.fields(stageData.preload))
						{
							var filters:Int = Reflect.field(stageData.preload, asset);
							var asset:String = asset.trim();

							if (filters < 0 || StageData.validateVisibility(filters))
							{
								if (asset.startsWith('images/'))
									imgs.push(asset.substr('images/'.length));
								else if (asset.startsWith('sounds/'))
									snds.push(asset.substr('sounds/'.length));
								else if (asset.startsWith('music/'))
									mscs.push(asset.substr('music/'.length));
							}
						}
					}

					if (stageData.objects != null)
					{
						for (sprite in stageData.objects)
						{
							if (sprite.type == 'sprite' || sprite.type == 'animatedSprite')
								if ((sprite.filters < 0 || StageData.validateVisibility(sprite.filters)) && !imgs.contains(sprite.image))
									imgs.push(sprite.image);
						}
					}
					prepare(imgs, snds, mscs);
				}

				AssetsToPrepare.get('songs').push('$folder/Inst');

				var player1:String = song.player1;
				var player2:String = song.player2;
				var gfVersion:String = song.gfVersion;
				var prefixVocals:String = song.needsVoices ? '$folder/Voices' : null;
				if (gfVersion == null)
					gfVersion = 'gf';

				dontPreloadDefaultVoices = false;
				preloadCharacter(player1, prefixVocals);
				if (!dontPreloadDefaultVoices && prefixVocals != null)
				{
					if (Paths.fileExists('$prefixVocals-Player.${Constants.SOUND_EXT}', SOUND, false, 'songs')
						&& Paths.fileExists('$prefixVocals-Opponent.${Constants.SOUND_EXT}', SOUND, false, 'songs'))
					{
						AssetsToPrepare.get('songs').push('$prefixVocals-Player');
						AssetsToPrepare.get('songs').push('$prefixVocals-Opponent');
					}
					else if (Paths.fileExists('$prefixVocals.${Constants.SOUND_EXT}', SOUND, false, 'songs'))
						AssetsToPrepare.get('songs').push(prefixVocals);
				}

				if (player2 != player1)
				{
					threadsMax++;
					threadPool.run(() ->
					{
						try
						{
							preloadCharacter(player2, prefixVocals);
						}
						catch (e:Dynamic)
						{
						}
						completedThread();
					});
				}
				if (!stageData.hide_girlfriend && gfVersion != player2 && gfVersion != player1)
				{
					threadsMax++;
					threadPool.run(() ->
					{
						try
						{
							preloadCharacter(gfVersion);
						}
						catch (e:Dynamic)
						{
						}
						completedThread();
					});
				}

				if (threadsCompleted == threadsMax)
				{
					clearInvalids();
					startThreads();
					initialThreadCompleted = true;
				}
				return true;
			}, isIntrusive)).onError((err:Dynamic) ->
			{
				trace('ERROR! while preparing song: $err');
			});
	}

	public static function clearInvalids()
	{
		clearInvalidFrom(AssetsToPrepare.get('images'), 'images', '${Constants.IMAGE_EXT}', IMAGE);
		clearInvalidFrom(AssetsToPrepare.get('sounds'), 'sounds', '.${Constants.SOUND_EXT}', SOUND);
		clearInvalidFrom(AssetsToPrepare.get('music'), 'music', ' .${Constants.SOUND_EXT}', SOUND);
		clearInvalidFrom(AssetsToPrepare.get('songs'), 'songs', '.${Constants.SOUND_EXT}', SOUND, 'songs');

		for (arr in [
			AssetsToPrepare.get('images'),
			AssetsToPrepare.get('sounds'),
			AssetsToPrepare.get('music'),
			AssetsToPrepare.get('songs')
		])
			while (arr.contains(null))
				arr.remove(null);
	}

	static function clearInvalidFrom(arr:Array<String>, prefix:String, ext:String, type:openfl.utils.AssetType, ?parentFolder:String = null)
	{
		for (folder in arr.copy())
		{
			var nam:String = folder.trim();
			if (nam.endsWith('/'))
			{
				for (subfolder in Mods.directoriesWithFile(Paths.getSharedPath(), '$prefix/$nam'))
				{
					for (file in FileSystem.readDirectory(subfolder))
					{
						if (file.endsWith(ext))
						{
							var toAdd:String = nam + haxe.io.Path.withoutExtension(file);
							if (!arr.contains(toAdd))
								arr.push(toAdd);
						}
					}
				}

				// trace('Folder detected! ' + folder);
			}
		}

		var i:Int = 0;
		while (i < arr.length)
		{
			var member:String = arr[i];
			var myKey = '$prefix/$member$ext';
			if (parentFolder == 'songs')
				myKey = '$member$ext';

			// trace('attempting on $prefix: $myKey');
			var doTrace:Bool = false;
			if (member.endsWith('/') || (!Paths.fileExists(myKey, type, false, parentFolder) && (doTrace = true)))
			{
				arr.remove(member);
				if (doTrace) trace('Removed invalid $prefix: $member');
			}
			else
				i++;
		}
	}

	public static function startThreads() : Void
	{
		mutex = new Mutex();
		loadMax = AssetsToPrepare.get('images').length + AssetsToPrepare.get('sounds').length + AssetsToPrepare.get('music').length + AssetsToPrepare.get('songs').length;
		loaded = 0;

		// then start threads
		_threadFunc();
	}

	static function _threadFunc()
	{
		_startPool();
		for (sound in AssetsToPrepare.get('sounds'))
			initThread(() -> preloadSound('sounds/$sound'), 'sound $sound');
		for (music in AssetsToPrepare.get('music'))
			initThread(() -> preloadSound('music/$music'), 'music $music');
		for (song in AssetsToPrepare.get('songs'))
			initThread(() -> preloadSound(song, 'songs', true, false), 'song $song');

		// for images, they get to have their own thread
		for (image in AssetsToPrepare.get('images'))
			initThread(() -> preloadGraphic(image), 'image $image');
	}

	static function initThread(func:Void->Dynamic, traceData:String)
	{
		// trace('scheduled $func in threadPool');
		#if debug
		final threadSchedule:Float = Sys.time();
		#end
		threadPool.run(() ->
		{
			#if debug
			final threadStart:Float = Sys.time();
			trace('$traceData took ${threadStart - threadSchedule}s to start preloading');
			#end

			try
			{
				if (func() != null)
				{
					#if debug Logs.prefixedTrace('finished preloading $traceData in ${Sys.time() - threadStart}s', 'LoadingState, DEBUG' ,GREEN); #end
				}
				else
					trace('ERROR! fail on preloading $traceData ');
			}
			catch (e:Dynamic)
			{
				trace('ERROR! fail on preloading $traceData: $e');
			}
			// mutex.acquire();
			loaded++;
			// mutex.release();
		});
	}

	inline private static function preloadCharacter(char:String, ?prefixVocals:String)
	{
		try
		{
			final path:String = Paths.getPath('characters/$char.json', TEXT);
			final character:Dynamic = tjson.TJSON.parse(#if MODS_ALLOWED File.getContent(path) #else Assets.getText(path) #end);
			final img:String = character.image.trim();

			var isAnimateAtlas:Bool = false;

			#if flxanimate
			var animToFind:String = Paths.getPath('images/$img/Animation.json', TEXT);
			if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
				isAnimateAtlas = true;
			#end

			if (!isAnimateAtlas)
			{
				var split:Array<String> = img.split(',');
				for (file in split)
					AssetsToPrepare.get('images').push(file.trim());
			}
			#if flxanimate
			else
			{
				for (i in 0...10)
				{
					var st:String = '$i';
					if (i == 0)
						st = '';

					if (Paths.fileExists('images/$img/spritemap$st.png', IMAGE))
					{
						AssetsToPrepare.get('images').push('$img/spritemap$st');
						break;
					}
				}
			}
			#end

			if (prefixVocals != null && character.vocals_file != null && character.vocals_file.length > 0)
			{
				AssetsToPrepare.get('songs').push(prefixVocals + "-" + character.vocals_file);
				if (char == PlayState.SONG.player1)
					dontPreloadDefaultVoices = true;
			}
		}
		catch (e:haxe.Exception)
		{
			trace(e.details());
		}
	}

	// thread safe sound loader
	static function preloadSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true):Null<Sound>
	{
		var file:String = Paths.getPath('$key.${Constants.SOUND_EXT}', SOUND, path, modsAllowed);

		// trace('precaching sound: $file');
		if (!Paths.currentTrackedSounds.exists(file))
		{
			if (#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file, SOUND))
			{
				var sound:Sound = #if sys Sound.fromFile(file) #else OpenFlAssets.getSound(file, false) #end;
				mutex.acquire();
				Paths.currentTrackedSounds.set(file, sound);
				mutex.release();
			}
			else if (beepOnNull)
			{
				trace('SOUND NOT FOUND: $key, PATH: $path');
				FlxG.log.error('SOUND NOT FOUND: $key, PATH: $path');
				return flixel.system.FlxAssets.getSound('flixel/sounds/beep');
			}
		}
		mutex.acquire();
		Paths.localTrackedAssets.push(file);
		mutex.release();

		return Paths.currentTrackedSounds.get(file);
	}

	// thread safe sound loader
	static function preloadGraphic(key:String):Null<BitmapData>
	{
		try
		{
			var requestKey:String = 'images/$key';
			if (requestKey.lastIndexOf('.') < 0)
				requestKey += '.png';

			if (!Paths.currentTrackedAssets.exists(requestKey))
			{
				var file:String = Paths.getPath(requestKey, IMAGE);
				if (#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file, IMAGE))
				{
					var bitmap:BitmapData = #if sys BitmapData.fromFile(file) #else OpenFlAssets.getBitmapData(file, false) #end;

					mutex.acquire();
					requestedBitmaps.set(file, bitmap);
					originalBitmapKeys.set(file, requestKey);
					mutex.release();
					return bitmap;
				}
				else
					Logs.prefixedTrace('no such image $key exists', 'Notice', YELLOW);
			}

			return Paths.currentTrackedAssets.get(requestKey).bitmap;
		}
		catch (e:haxe.Exception)
			Logs.prefixedTrace('fail on preloading image $key', 'ERROR', RED);

		return null;
	}
}
