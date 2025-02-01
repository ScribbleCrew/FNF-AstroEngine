package funkin.backend.initialization;

/**
* Uhh, simple script, probs going to add globalscript. -orbl
* Basically, it creates a .temp folder that doesn't contain anything at the moment but will in the future.
* very simple, lol...
*/
class TemporaryFolder {
    static function main():Void {
        Paths.temp = FileUtil.createDirectory(".temp", true);
        
		openfl.Lib.current.stage.application.onExit.add((_)->FileUtil.deleteDirectory(".temp") );
    }
}