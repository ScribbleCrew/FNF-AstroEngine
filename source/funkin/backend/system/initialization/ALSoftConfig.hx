package funkin.backend.system.initialization;

#if desktop
import haxe.io.Path;

/*
 *	A class that simply points OpenALSoft to a custom configuration file when the game starts up.
 *	The config overrides a few global OpenALSoft settings with the aim of improving audio quality on desktop targets.
 */
@:keep class ALSoftConfig
{
	static function __init__():Void
	{
		var configPath:String = Path.directory(Path.withoutExtension(FileUtil.originPath/*#if hl Sys.getCwd() #else Sys.programPath() #end*/));
		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
	}
}
#end