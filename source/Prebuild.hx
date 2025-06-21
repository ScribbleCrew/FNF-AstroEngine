package source;

#if !display
import sys.io.File;

class Prebuild
{
	static public inline final BUILD_TIME_FILE:String = '.build_time';

	static function main():Void
	{
		try
		{
			final fileOutput:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
			final time:Float = Sys.time();
			fileOutput.writeDouble(time);
			fileOutput.close();

			trace('i like men');
		}
		catch (error:Dynamic)
		{
			
		}
	}
}
#end
