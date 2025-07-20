package funkin.modding;

#if GLOBAL_SCRIPT
import funkin.backend.system.MusicBeatState.checkScriptExtensions;

@:access(funkin.backend.system.MusicBeatState.checkScriptExtensions)
class GlobalScript
{
	public static var scripts:ScriptPack;

	public static function reload()
	{
		if (scripts != null)
		{
			scripts.call('destroy');
			scripts = FlxDestroyUtil.destroy(scripts);
		}
		scripts = new ScriptPack();
		for (folderName in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/modules/')) // stolen from the `executeClassScripts`
		{
			for (_fileName in FileSystem.readDirectory(folderName))
			{
				trace(_fileName);
				if (!checkScriptExtensions(_fileName))
					continue;

				if (_fileName.startsWith("~"))
					continue;

				final convertedScriptPath:String = folderName + _fileName;
				final convertedScriptName:String = _fileName.substr(0, _fileName.lastIndexOf('.')).toLowerCase();

				#if LUA_ALLOWED
				if (checkScriptExtensions(_fileName, "lua"))
					scripts.add(new FunkinLua(convertedScriptPath));
				#end
				#if HSCRIPT_ALLOWED
				if (checkScriptExtensions(_fileName, "haxe"))
					scripts.add(new HScript(null, convertedScriptPath));
				#end
				scripts.run();
			}
		}
		scripts.run();
		// for(i in )
	}

	public static function init():Void
	{
		reload();

		///

		Conductor.onBeatHit.add(_ -> scripts.call("beatHit", [_]));
		Conductor.onStepHit.add(_ -> scripts.call("stepHit", [_]));

		FlxG.signals.focusGained.add(() -> scripts.call("focusGained"));

		FlxG.signals.focusLost.add(() -> scripts.call("focusLost"));

		FlxG.signals.gameResized.add((w:Int, h:Int) -> scripts.call("gameResized", [w, h]));
		FlxG.signals.postDraw.add(() -> scripts.call("postDraw"));
		FlxG.signals.postGameReset.add(() -> scripts.call("postGameReset"));
		FlxG.signals.postGameStart.add(() -> scripts.call("postGameStart"));
		FlxG.signals.postStateSwitch.add(() -> scripts.call("postStateSwitch"));

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
	}
}
#end
