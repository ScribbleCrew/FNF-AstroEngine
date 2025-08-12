package funkin.modding;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
#if GLOBAL_SCRIPT
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.modding.Script.ScriptType as TScript;
import openfl.utils.Assets;
import haxe.ds.StringMap;

class GlobalScript
{
	//
	// PUBLIC HELPERS
	//
	public static function call(event:String, ?args:Array<Dynamic>, ?scriptType:TScript):Dynamic
		return scripts.call(event, args, scriptType);

	public static function set(name:String, value:Dynamic, ?scriptType:TScript):Void
		scripts.set(name, value, scriptType);

	public static var scripts:ScriptPack;
	public static var onModSwitch:FlxTypedSignal<Void->Void> = new FlxTypedSignal();

	public static function reload():Void
	{
		final more : Bool = (scripts?.scripts.length > 0) ?? true;
		Logs.log(scripts == null ? 'No global script instance reloading...' : (more ? 'Reloading global scripts...' : 'No global scripts to reload...'), YELLOW);
		
		destroy();

		scripts = new ScriptPack();
		loadScripts(Paths.getSharedPath(), 'scripts/modules/');

		if(more)
			Logs.log('Global script successfully reloaded.', YELLOW);
	}

	static var loadedScripts : StringMap<Bool> = new StringMap<Bool>();

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

				if (loadedScripts.exists(convertedScriptPath))
					continue;

				#if LUA_ALLOWED
				if (Script.checkScriptExtensions(_fileName, "lua"))
				{
					scripts.add(new FunkinLua(convertedScriptPath));
					loadedScripts.set(convertedScriptPath, true);
				}
				#end
				#if HSCRIPT_ALLOWED
				if (Script.checkScriptExtensions(_fileName, "haxe"))
				{
					scripts.add(new HScript(null, convertedScriptPath));
					loadedScripts.set(convertedScriptPath, true);
				}
				#end

				loadedScripts.set(convertedScriptPath, true);
			}

			var prefix = if (!folderName.endsWith("/")) folderName + "/" else folderName;

			// Embedded assets
			for (asset in Assets.list())
			{
				if (!asset.startsWith(prefix)) continue;
				final relative : String = asset.substr(prefix.length);
				if (relative.contains("/")) continue;
				if (!Script.checkScriptExtensions(relative)) continue;
				if (!relative.startsWith("MODULE_")) continue;

				final convertedScriptPath:String = prefix + relative;
				if (loadedScripts.exists(convertedScriptPath)) continue;

				#if LUA_ALLOWED
				if (Script.checkScriptExtensions(relative, "lua"))
				{
					scripts.add(new FunkinLua(convertedScriptPath));
					loadedScripts.set(convertedScriptPath, true);
				}
				#end

				#if HSCRIPT_ALLOWED
				if (Script.checkScriptExtensions(relative, "haxe"))
				{
					scripts.add(new HScript(null, convertedScriptPath));
					loadedScripts.set(convertedScriptPath, true);
				}
				#end
			}
		}

		scripts.run();
	}

	public static function init():Void
	{
		onModSwitch.add(reload);
		onModSwitch.add(() -> Logs.log('Loading global scripts...', YELLOW));
		onModSwitch.dispatch();

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
			scripts.call("preUpdate", [FlxG.elapsed]);
			scripts.call("update", [FlxG.elapsed]);
		});

		FlxG.signals.postUpdate.add(() ->
		{
			FlxG.watch.addQuick("Loaded Scripts", scripts.scripts.length);
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
	}

	public static function destroy():Void
	{
		if (scripts != null)
		{
			scripts.call('destroy');
			scripts = FlxDestroyUtil.destroy(scripts);
		}
	}
}
#end
