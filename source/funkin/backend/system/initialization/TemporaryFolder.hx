package funkin.backend.system.initialization;

#if desktop
/**
* Uhh, simple script, probs going to add globalscript. -orbl
* Basically, it creates a .temp folder that doesn't contain anything at the moment but will in the future.
* very simple, lol...
*/
@:keep class TemporaryFolder {
    @:allow(funkin.game.Init)
    static function init():Void{
        Paths.temp = FileUtil.createDirectory(".temp", true);
		openfl.Lib.current.stage.application.onExit.add((_)->FileUtil.deleteDirectory(".temp") );
    }
}
#end