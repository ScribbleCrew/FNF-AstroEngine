package funkin.backend.system.initialization;

#if desktop
/**
 * Uhh, simple script, probs going to add globalscript. -orbl
 * Basically, it creates a .temp folder that doesn't contain anything at the moment but will in the future.
 * very simple, lol...
 */
class TemporaryFolder
{
	/**	
	 * Just da init.
	 */
	@:allow(funkin.game.Init)
	static function init():Void
	{
		/**	
		 * Create the directory and set `Paths.temporaryPath` to the returned directory path
		 */
		Paths.temporaryPath = FileUtil.createDirectory(".temp", true);

		/**	
		 * Set an event which deletes the dir once the game has exited.
		 */
		openfl.Lib.current.stage.application.onExit.add((_) -> FileUtil.deleteDirectory(".temp"));
	}
}
#end
