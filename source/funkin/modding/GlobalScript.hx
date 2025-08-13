package funkin.modding;

#if GLOBAL_SCRIPT
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.modding.Script.ScriptType;
import openfl.utils.Assets;
import haxe.ds.StringMap;

class GlobalScript
{
	public static var scripts:ScriptPack;
	
	#if MODS_ALLOWED
	public static var onModSwitch:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	#end
	
	/**
	 * [Description] Reloads the global scripts.
	 * This will destroy the current scripts and load new ones from the shared path.
	 * If there are no scripts to reload, it will log a message.
	 * @return Void
	 */
	public static function reload():Void
	{
		final __hasScripts:Bool = (scripts?.scripts.length > 0) ?? true;
		Logs.log(scripts == null ? 'No global script instance reloading...' : (__hasScripts ? 'Reloading global scripts...' : 'No global scripts to reload...'), YELLOW);

		destroy();

		scripts = new ScriptPack();
		loadScripts(Paths.getSharedPath(), 'scripts/modules/');

		if (__hasScripts)
			Logs.log('Global script successfully reloaded.', YELLOW);
	}

	public static function loadScripts(path:String, fileToFind:String):Void
	{
		for (folderName in Mods.directoriesWithFile(path, fileToFind))
		{
			// Filesystem files
			for (_fileName in FileSystem.readDirectory(folderName))
			{
				if (!Script.checkScriptExtensions(_fileName))
					continue;
				if (!_fileName.startsWith("MODULE_"))
					continue;

				final convertedScriptPath:String = folderName + _fileName;

				if (__loadedScripts.exists(convertedScriptPath))
					continue;
				trace('Loading script: ' + convertedScriptPath);
				#if LUA_ALLOWED
				if (Script.checkScriptExtensions(_fileName, "lua"))
				{
					scripts.add(new FunkinLua(convertedScriptPath));
					__loadedScripts.set(convertedScriptPath, true);
				}
				#end
				#if HSCRIPT_ALLOWED
				if (Script.checkScriptExtensions(_fileName, "haxe"))
				{
					scripts.add(new HScript(null, convertedScriptPath));
					__loadedScripts.set(convertedScriptPath, true);
				}
				#end

				__loadedScripts.set(convertedScriptPath, true);
			}

			var prefix = if (!folderName.endsWith("/")) folderName + "/" else folderName;

			// Embedded assets
			for (asset in Assets.list())
			{
				if (!asset.startsWith(prefix))
					continue;
				final relative:String = asset.substr(prefix.length);
				if (relative.contains("/"))
					continue;
				if (!Script.checkScriptExtensions(relative))
					continue;
				if (!relative.startsWith("MODULE_"))
					continue;

				final convertedScriptPath:String = prefix + relative;
				if (__loadedScripts.exists(convertedScriptPath))
				{
					continue;
				}

				trace('Loading script: ' + convertedScriptPath);

				#if LUA_ALLOWED
				if (Script.checkScriptExtensions(relative, "lua"))
				{
					scripts.add(new FunkinLua(convertedScriptPath));
					__loadedScripts.set(convertedScriptPath, true);
				}
				#end

				#if HSCRIPT_ALLOWED
				if (Script.checkScriptExtensions(relative, "haxe"))
				{
					scripts.add(new HScript(null, convertedScriptPath));
					__loadedScripts.set(convertedScriptPath, true);
				}
				#end
			}
		}

		scripts.run();
	}

	public static function init():Void
	{
		#if MODS_ALLOWED
		onModSwitch.add(reload);
		onModSwitch.add(() -> Logs.log('Loading global scripts...', YELLOW));
		onModSwitch.dispatch();
		#end

		///

		Conductor.onBeatHit.add(_ -> scripts.call("beatHit", [_]));
		Conductor.onStepHit.add(_ -> scripts.call("stepHit", [_]));
		Conductor.onBPMChange.add(_ -> scripts.call("onBPMChange", [_]));

		FlxG.signals.focusGained.add(() -> scripts.call("focusGained"));
		FlxG.signals.focusLost.add(() -> scripts.call("focusLost"));
		FlxG.signals.gameResized.add((w:Int, h:Int) -> scripts.call("gameResized", [w, h]));
		FlxG.signals.postDraw.add(() -> scripts.call("postDraw"));
		FlxG.signals.postGameReset.add(() -> scripts.call("postGameReset"));
		FlxG.signals.postGameStart.add(() -> scripts.call("postGameStart"));
		FlxG.signals.postStateSwitch.add(() -> scripts.call("postStateSwitch"));

		FlxG.signals.preDraw.add(() -> scripts.call("preDraw"));
		FlxG.signals.preGameReset.add(() -> scripts.call("preGameReset"));
		FlxG.signals.preGameStart.add(() -> scripts.call("preGameStart"));
		FlxG.signals.preStateCreate.add((state:FlxState) -> scripts.call("preStateCreate", [state]));
		FlxG.signals.preStateSwitch.add(() -> scripts.call("preStateSwitch", []));

		FlxG.signals.preUpdate.add(() ->
		{
			FlxG.watch.addQuick("Loaded Scripts", scripts.scripts.length);

			scripts.call("preUpdate", [FlxG.elapsed]);
			scripts.call("update", [FlxG.elapsed]);
		});

		FlxG.signals.postUpdate.add(() ->
		{
			if (FlxG.keys.justPressed.F5)
			{
				if (scripts.scripts.length > 0)
				{
					Logs.log('Reloading global scripts...', YELLOW);
					reload();
					Logs.log('Global script successfully reloaded.', YELLOW);
				}
				else
				{
					Logs.log('No global scripts to reload...', YELLOW);
					reload();
				}
			}
			scripts.call("postUpdate", [FlxG.elapsed]);
		});

		Application.current.onExit.add(_->destroy());
	}

	/**
	 * [Description] A map of loaded scripts.
	 * This is used to prevent loading the same script multiple times.
	 */
	@:dox(hide) @:noCompletion static var __loadedScripts:StringMap<Bool> = new StringMap<Bool>();

	public static function destroy():Void
	{
		if(__loadedScripts!=null) __loadedScripts.clear();
		if (scripts != null)
		{
			scripts.call('destroy');
			scripts = FlxDestroyUtil.destroy(scripts);
		}
	}

		//
	// PUBLIC HELPERS
	//

	/**
	 * [Description] calls a global script function.
	 * @param event is the name of the function to call. 
	 * @param args is an array of arguments to pass to the function.
	 * @param scriptType is the type of script to call. If not provided, it defaults to `ScriptType.HSCRIPT`.
	 * @return Dynamic return scripts.call(event, args, scriptType)
	 */
	public static function call(event:String, ?args:Array<Dynamic>, ?scriptType:ScriptType):Dynamic
	{
		return scripts.call(event, args, scriptType);
	}

	/**
	 * [Description] sets a global script variable.
	 * @param name is the name of the variable to set.
	 * @param value is the value to set the variable to.
	 * @param scriptType is the type of script to set the variable in. If not provided, it defaults to `ScriptType.HSCRIPT`.
	 * @return Void
	 */
	public static function set(name:String, value:Dynamic, ?scriptType:ScriptType):Void
	{
		scripts.set(name, value, scriptType);
	}
}
#end
