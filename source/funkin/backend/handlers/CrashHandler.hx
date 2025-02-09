package funkin.backend.handlers;

#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.io.File;

class CrashHandler
{
	public static function main(e:UncaughtErrorEvent):Void
	{
		final callStack:Array<StackItem> = CallStack.exceptionStack(true);
		final dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
		final path:String = './crash/${Application.current.meta.get('file')}_$dateNow.txt';

		var errMsg:String = "";

		trace(path);

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page:"
			+ EngineData.REPOSITORY
			+ "\n\n---------------------------------------------------------\n> Crash Handler written by: sqirra-rng";

		if (!FileUtil.validDirectory("./crash/")) FileUtil.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED DiscordClient.shutdown(); #end
		Sys.exit(1);
	}
}
#end
