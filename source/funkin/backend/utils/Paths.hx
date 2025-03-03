package funkin.backend.utils;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import openfl.system.System;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;

import haxe.xml.Access;
import flash.media.Sound;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

/**
 * Paths cuz very cool
 */
@:access(flash.media.Sound)
@:access(openfl.display.BitmapData)
@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
class Paths
{
	/**
	* TEMP file path, mainly used for store temp data for modpacks
	*/
	#if MODS_ALLOWED public static var temporaryPath:Null<String> = null;#end

	/**
	 * An array for all locally tracks assets.
	 */
	public static var localTrackedAssets:Array<String> = [];

	/**
	 * Files that are excluded from being dumped.
	 */
	public static var exclusions:Array<String> = [
		/**
		 * Funkin Music.
		 * freakyMenu.(ogg/mp3).
		 */
		'assets/music/freakyMenu.${Constants.SOUND_EXT}',

		/**
		 * Pause Menu Music.
		 * breakfast.(ogg/mp3).
		 */
		'assets/shared/music/breakfast.${Constants.SOUND_EXT}',

		/**
		 * Pause Menu Music.
		 * tea-time.(ogg/mp3).
		 */
		'assets/shared/music/tea-time.${Constants.SOUND_EXT}',
	];

	/**
	 * The current library level. Mainly used to
	 * point data shit to the correct lib (or whatever).
	 */
	@:isVar public static var currentLevel(default, set):String;
	@:dox(hide) static inline function set_currentLevel(level:String):String
		return currentLevel = level.toLowerCase();

	/**
	 * The current library level. Mainly used to
	 * point data shit to the correct lib (or whatever).
	 */
	public inline static function excludeAsset(key:String):Void
		return if (!exclusions.contains(key)) exclusions.push(key);

	/**
	 * If the asset is inisde of `exclusions` to be excluded from being dumped.
	 */
	public inline static function includeAsset(key:String):Void
		return if (exclusions.contains(key)) exclusions.remove(key);

	/**
	 * Clears all tracked unused memory.
	 * haya I love you for the base cache dump I took to the max.
	 */
	public static function clearUnusedMemory():Void
	{
		/**
		 * clear non local assets in the tracked assets list
		 */
		for (key in currentTrackedAssets.keys())
		{
			/**
			 * if it is not currently contained within the used local assets
			 */
			if (!localTrackedAssets.contains(key) && !exclusions.contains(key))
			{
				/**
				 * get rid of the graphic
				 */
				destroyGraphic(currentTrackedAssets.get(key));

				/**
				 * and remove the key from local cache map
				 */
				currentTrackedAssets.remove(key);
			}
		}

		/**
		 * run the garbage collector for good measure lmfao
		 */
		System.gc();
	}

	/**
	 * Clears all tracked unused memory.
	 * haya I love you for the base cache dump I took to the max
	 */
	public static function freeGraphicsFromMemory():Void
	{
		/**
		 * run the garbage collector for good measure lmfao
		 */
		var protectedGraphics:Array<FlxGraphic> = [];

		/**
		 * Checks if the sprite has a graphic.
		 */
		function checkForGraphics(spr:Dynamic):Void
		{
			/**
			* Checks if it's a FlxGroup (TODO: add normal array support).
			*/
			try
			{
				/**
				 * Gets the members of a group.
				 */
				final group:Array<Dynamic> = Reflect.getProperty(spr, 'members'); // is reflect rlly needed?

				if (group != null)
				{
					/**
					 * Checks every member with `checkForGraphics`.
					 */
					for (member in group) checkForGraphics(member);

					/**
					* Returns if a group.	
					*/
					return;
				}
			} catch (error:Dynamic) {}

			/**
			 * Checks if it's a sprite with var `graphic`.
			 */
			try
			{
				/**
				 * Gets the `graphic` variable from the sprite in question.
				 */
				final spriteGraphic:FlxGraphic = Reflect.getProperty(spr, 'graphic');

				/**
				 * If the graphic doesn't equal null then push to `protectedGraphics` group.
				 */
				if (spriteGraphic != null)
					protectedGraphics.push(spriteGraphic);
			} catch (error:Dynamic) {}
		}

		/**
		 * Checks if all members inside `FlxG.state` has a graphic.
		 */
		for (member in FlxG.state.members)
		{
			/**
			 * Checks with the obj has a graphic.
			 */
			checkForGraphics(member);
		}

		/**
		 * Checks if all members inside `FlxG.state.subState` has a graphic.
		 */
		if (FlxG.state.subState != null)
		{
			/**
			 * For loop for all members inside `FlxG.state.subState.members`
			 */
			for (member in FlxG.state.subState.members)
			{
				/**
				 * Checks with the obj has a graphic.
				 */
				checkForGraphics(member);
			}
		}

		/**
		 * Destroys all graphics inside of `currentTrackedAssets.keys()`.
		 */
		for (key in currentTrackedAssets.keys())
		{
			/**
			 * if it is not currently contained within the used local assets
			 */
			if (!exclusions.contains(key))
			{
				/**
				 * Gather the asset in question.
				 */
				final graphic:FlxGraphic = currentTrackedAssets.get(key);

				/**
				 * Checks if `protectedGraphics` contains the graphic.
				 */
				if (!protectedGraphics.contains(graphic))
				{
					/**
					 * Get rid of the graphic.
					 */
					destroyGraphic(graphic); // get rid of the graphic

					/**
					 * Removes the asset key from the local cache list.
					 */
					currentTrackedAssets.remove(key);
				}
			}
		}
	}
	
	/**
	 * run the garbage collector for good measure lmfao
	 */
	public static function clearStoredMemory():Void
	{
		// clear anything not in the tracked assets list
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !exclusions.contains(key) && asset != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	/**
	 * Clears all tracked unused memory.
	 */
	inline static function destroyGraphic(graphic:FlxGraphic):Void
	{
		// free some gpu memory
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		return FlxG.bitmap.remove(graphic);
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentfolder:String, ?modsAllowed:Bool = true):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			var customFile:String = file;
			if (parentfolder != null)
				customFile = '$parentfolder/$file';

			var modded:String = modFolders(customFile);
			if (FileSystem.exists(modded))
				return modded;
		}
		#end

		if (parentfolder != null)
			return getFolderPath(file, parentfolder);

		if (currentLevel != null && currentLevel != 'shared')
		{
			var levelPath = getFolderPath(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}
		return getSharedPath(file);
	}

	static public function getLibraryPath(file:String, library = "shared")
	{
		return if (library == "shared") getSharedPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String, ?level:String)
	{
		if (level == null)
			level = library;
		var returnPath = '$library:assets/$level/$file';
		return returnPath;
	}

	inline static public function getFolderPath(file:String, folder = "shared")
		return 'assets/$folder/$file';

	inline public static function getSharedPath(file:String = '')
	{
		return 'assets/shared/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}

	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(videoKey:String)
	{
		#if MODS_ALLOWED
		final videoPath:String = modsVideo(videoKey);
		if (FileSystem.exists(videoPath)) return videoPath;
		#end
		return 'assets/videos/$videoKey.${Constants.VIDEO_EXT}';
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?modsAllowed:Bool = true)
		return sound(key + FlxG.random.int(min, max), modsAllowed);

	inline static public function sound(key:String, ?modsAllowed:Bool = true):Sound
		return returnSound('sounds/$key', modsAllowed);

	inline static public function music(key:String, ?modsAllowed:Bool = true):Sound
		return returnSound('music/$key', modsAllowed);

	inline static public function inst(song:String, ?modsAllowed:Bool = true):Sound
		return returnSound('${formatToSongPath(song)}/Inst', 'songs', modsAllowed);

	inline static public function voices(song:String, postfix:String = null, ?modsAllowed:Bool = true):Sound
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if (postfix != null)
			songKey += '-' + postfix;
		// trace('songKey test: $songKey');
		return returnSound(songKey, 'songs', modsAllowed, false);
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	static public function image(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxGraphic
	{
		key = 'images/$key.png';
		var bitmap:BitmapData = null;
		if (currentTrackedAssets.exists(key))
		{
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		return cacheBitmap(key, parentFolder, bitmap, allowGPU);
	}

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic
	{
		if (bitmap == null)
		{
			var file:String = getPath(key, IMAGE, parentFolder, true);
			#if MODS_ALLOWED if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else #end if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);

			if (bitmap == null)
			{
				trace('Bitmap not found: $file | key: $key');
				return null;
			}
		}

		if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null)
		{
			bitmap.lock();
			if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}

		var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}

	inline static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		final path:String = getPath(key, TEXT, !ignoreMods);
		#if sys
		return (FileSystem.exists(path)) ? File.getContent(path) : null;
		#else
		return (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
		#end
	}

	// isn't protected, you'll need to do that yourself.
	static public function xmlAccess(path, ?mods:Bool = true):Access
		return new Access(Xml.parse(!mods ? getTextFromFile(path, !mods) : File.getContent(path)).firstElement());

	inline static public function font(key:String):String
	{
		#if MODS_ALLOWED
		final file:String = modsFont(key);
		if (FileSystem.exists(file))
			return file;
		#end
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String):Bool
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(mods(key)))
			return true;
		#end
		if (OpenFlAssets.exists(getPath(key, type)))
			return true;
		return false;
	}

	static public function getAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var useMod = false;

		final loadedImage:FlxGraphic = image(key, parentFolder);
		final myXml:Dynamic = getPath('images/$key.xml', TEXT, parentFolder, true);

		if (OpenFlAssets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod = true)) #end)
		{
			#if MODS_ALLOWED
			return FlxAtlasFrames.fromSparrow(loadedImage, (useMod ? File.getContent(myXml) : myXml));
			#else
			return FlxAtlasFrames.fromSparrow(loadedImage, myXml);
			#end
		}
		else
		{
			var myJson:Dynamic = getPath('images/$key.json', TEXT, parentFolder, true);
			if (OpenFlAssets.exists(myJson) #if MODS_ALLOWED || (FileSystem.exists(myJson) && (useMod = true)) #end)
			{
				#if MODS_ALLOWED
				return FlxAtlasFrames.fromTexturePackerJson(loadedImage, (useMod ? File.getContent(myJson) : myJson));
				#else
				return FlxAtlasFrames.fromTexturePackerJson(loadedImage, myJson);
				#end
			}
		}
		return getPackerAtlas(key, parentFolder);
	}

	inline static public function getSparrowAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		#if MODS_ALLOWED
		var xmlExists:Bool = false;

		var xml:String = modsXml(key);
		if (FileSystem.exists(xml))
			xmlExists = true;

		return FlxAtlasFrames.fromSparrow(imageLoaded, (xmlExists ? File.getContent(xml) : getPath('images/$key.xml', TEXT, parentFolder)));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/$key.xml', TEXT, parentFolder));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		#if MODS_ALLOWED
		var txtExists:Bool = false;

		var txt:String = modsTxt(key);
		if (FileSystem.exists(txt))
			txtExists = true;

		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, (txtExists ? File.getContent(txt) : getPath('images/$key.txt', TEXT, parentFolder)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath('images/$key.txt', TEXT, parentFolder));
		#end
	}

	inline static public function getAsepriteAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		#if MODS_ALLOWED
		var jsonExists:Bool = false;

		var json:String = modsImagesJson(key);
		if (FileSystem.exists(json))
			jsonExists = true;

		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (jsonExists ? File.getContent(json) : getPath('images/$key.json', TEXT, parentFolder)));
		#else
		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, getPath('images/$key.json', TEXT, parentFolder));
		#end
	}

	inline static public function formatToSongPath(path:String)
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true)
	{
		var file:String = getPath('$key.${Constants.SOUND_EXT}', SOUND, path, modsAllowed);

		//trace('precaching sound: $file');
		if(!currentTrackedSounds.exists(file))
		{
			#if sys
			if(FileSystem.exists(file))
				currentTrackedSounds.set(file, Sound.fromFile(file));
			#else
			if(OpenFlAssets.exists(file, SOUND))
				currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
			#end
			else if(beepOnNull)
			{
				trace('SOUND NOT FOUND: $key, PATH: $path');
				FlxG.log.error('SOUND NOT FOUND: $key, PATH: $path');
				return FlxAssets.getSound('flixel/sounds/beep');
			}
		}
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}

	#if MODS_ALLOWED
	/**
	 * Returns either a file inside the mods folder or if
	 * the arg is left empty returns the path.
	 *
	 * @param key the name of the file.
	 */
	inline static public function mods(key:String = ''):String
		return 'mods/$key';
	

	/**
	 * Grabs a the specified font from the mod folder.	
	 *
	 * @param key the name of the file.
	 */
	inline static public function modsFont(key:String = ''):String
		return modFolders('fonts/$key');

	/**
	 * Grabs a the specified xml from the data folder inside mods.	
	 *
	 * @param key The name of the xml file.
	 */
	inline static public function modsDataXML(key:String):String
		return modFolders('data/${key.contains('.xml') ? key : '$key.xml'}');//gwa do for all

	/**
	 * Returns a json file from the mods folder.
	 * @param key The name of the json file.
	 */
	inline static public function modsJson(key:String):String
		return modFolders('data/${key.contains('.json') ? key : '$key.json'}');

	inline static public function modsVideo(key:String):String
		return modFolders('videos/$key.${Constants.VIDEO_EXT}');

	inline static public function modsSounds(path:String, key:String)
		return modFolders(path + '/' + key + '.' + Constants.SOUND_EXT);

	inline static public function modsImages(key:String)
		return modFolders('images/' + key + '.png');

	inline static public function modsXml(key:String)
		return modFolders('images/' + key + '.xml');

	inline static public function modsTxt(key:String)
		return modFolders('images/' + key + '.txt');

	inline static public function modsImagesJson(key:String)
		return modFolders('images/' + key + '.json');

	static public function modFolders(key:String)
	{
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
		{
			final fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			if (FileSystem.exists(fileToCheck)) return fileToCheck;
		}

		for (mod in Mods.getGlobalMods())
		{
			final fileToCheck:String = mods(mod + '/' + key);
			if (FileSystem.exists(fileToCheck))
				return fileToCheck;
		}

		return 'mods/' + key;
	}
	#end

	#if FLXANIMATE_ALLOWED
	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		var changedAnimJson:Bool = false;
		var changedAtlasJson:Bool = false;
		var changedImage:Bool = false;

		if (spriteJson != null)
		{
			changedAtlasJson = true;
			spriteJson = File.getContent(spriteJson);
		}

		if (animationJson != null)
		{
			changedAnimJson = true;
			animationJson = File.getContent(animationJson);
		}

		// is folder or image path
		if (Std.isOfType(folderOrImg, String))
		{
			final originalPath:String = folderOrImg;
			for (i in 0...10)
			{
				final st:String = i == 0 ? '' : '$i';

				if (!changedAtlasJson)
				{
					spriteJson = getTextFromFile('images/$originalPath/spritemap$st.json');
					if (spriteJson != null)
					{
						changedImage = true;
						changedAtlasJson = true;
						folderOrImg = image('$originalPath/spritemap$st');
						break;
					}
				}
				else if (fileExists('images/$originalPath/spritemap$st.png', IMAGE))
				{
					changedImage = true;
					folderOrImg = image('$originalPath/spritemap$st');
					break;
				}
			}

			if (!changedImage)
			{
				changedImage = true;
				folderOrImg = image(originalPath);
			}

			if (!changedAnimJson)
			{
				changedAnimJson = true;
				animationJson = getTextFromFile('images/$originalPath/Animation.json');
			}
		}

		spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
	}
	#end
}
