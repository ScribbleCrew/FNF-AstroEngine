package source; // Yeah, I know...

/**
 * A script which executes after the game is built.
 */
class Postbuild
{
  static inline final BUILD_TIME_FILE:String = '.build_time';

  static function main():Void
  {
    printBuildTime();
  }

  static function printBuildTime():Void
  {
    // get buildEnd before fs operations since they are blocking
    var end:Float = Sys.time();
    if (sys.FileSystem.exists(BUILD_TIME_FILE))
    {
      final fi:sys.io.FileInput = sys.io.File.read(BUILD_TIME_FILE);
      final start:Float = fi.readDouble();
      fi.close();

      sys.FileSystem.deleteFile(BUILD_TIME_FILE);

      final buildTime:Float = Math.round((end - start) * 100) / 100;

      trace('Build took: ${buildTime} seconds');
    }
  }
}