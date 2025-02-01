package source; // Yeah, I know...

/**
 * A script which executes after the game is built.
 */
final class Postbuild
{
	static inline final BUILD_TIME_FILE:String = '.build_time';

	static function main():Void
	{
		final endTime:Float = Sys.time();

		if (sys.FileSystem.exists(BUILD_TIME_FILE))
		{
			final _fileInput:sys.io.FileInput = sys.io.File.read(BUILD_TIME_FILE);
			final startTime:Float = _fileInput.readDouble();
			_fileInput.close();

			sys.FileSystem.deleteFile(BUILD_TIME_FILE);

			final buildTime:Float = Math.round((endTime - startTime) * 100) / 100;

			trace('Build took: ${buildTime} seconds');
		}
	}
}
