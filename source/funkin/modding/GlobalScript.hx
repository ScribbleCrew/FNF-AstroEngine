package funkin.modding;

#if GLOBAL_SCRIPT
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.modding.Script.ScriptType as TScript;
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
		if (scripts != null)
		{
			scripts.call('destroy');
			scripts = FlxDestroyUtil.destroy(scripts);
		}

		scripts = new ScriptPack();

		loadScripts();
		scripts.run();
		// for(i in )
	}

	static function loadScripts()
	{
		for (folderName in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/modules/'))
		{
			for (_fileName in FileSystem.readDirectory(folderName))
			{
				if (!MusicBeatState.checkScriptExtensions(_fileName))
					continue;
				if (!_fileName.startsWith("MODULE_"))
					continue;

				final convertedScriptPath:String = folderName + _fileName;
				#if LUA_ALLOWED
				if (MusicBeatState.checkScriptExtensions(_fileName, "lua"))
					scripts.add(new FunkinLua(convertedScriptPath));
				#end
				#if HSCRIPT_ALLOWED
				if (MusicBeatState.checkScriptExtensions(_fileName, "haxe"))
					scripts.add(new HScript(null, convertedScriptPath));
				#end
				scripts.run();
			}
		}
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
