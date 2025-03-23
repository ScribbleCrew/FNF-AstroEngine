package source; // Yeah, I know...

import haxe.Log;
import sys.io.File;
import source.Prebuild;
import sys.io.FileInput;
/**
 * A script which executes after the game is built.
 */
class Postbuild
{
	static inline final ROUND_TO = 1000.0;

	static function main():Void
	{
		final endTime:Float = Sys.time();

		if (sys.FileSystem.exists(Prebuild.BUILD_TIME_FILE))
		{
			final file:FileInput = File.read(Prebuild.BUILD_TIME_FILE);
			final start:Float = file.readDouble();

			final buildTime:Float = Math.round((endTime - start) * ROUND_TO) / ROUND_TO;
			Log.trace('Build complete in $buildTime seconds!', null);

			// cleanup
			file.close();
			sys.FileSystem.deleteFile(Prebuild.BUILD_TIME_FILE);
		} else {
			Log.trace('Build complete!', null);
		}
	}
}
