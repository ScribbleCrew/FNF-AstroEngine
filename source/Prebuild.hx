package source;
#if !display
import sys.io.File;

@:final class Prebuild
{
	inline static final title:String = "
    ▄▀█ █▀ ▀█▀ █▀█ █▀█   █▀▀ █▄░█ █▀▀ █ █▄░█ █▀▀
    █▀█ ▄█ ░█░ █▀▄ █▄█   ██▄ █░▀█ █▄█ █ █░▀█ ██▄
  ";

	inline static final subtitle:String = "
          █▀▀ █▀█ █▀▄▀█ █▀█ █ █░░ █▀▀ █▀█
          █▄▄ █▄█ █░▀░█ █▀▀ █ █▄▄ ██▄ █▀▄
  ";
	inline static final lines:String = "
    --------------------------------------------
  ";

	inline static final owoquote:String = "
            erm, what the sigma? :3c
  ";

	inline static final binded:String = '$lines$title$subtitle$owoquote$lines';

	static inline final BUILD_TIME_FILE:String = '.build_time';

	static function main():Void
	{
		// trace('Building!');
		saveBuildTime();
		trace('AE Compiler....');
	}

	static function saveBuildTime():Void
	{
		var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
		var now:Float = Sys.time();
		fo.writeDouble(now);
		fo.close();
	}
}
#end
