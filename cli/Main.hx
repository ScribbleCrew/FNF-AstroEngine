package;

import haxe.io.Eof;
import haxe.xml.Access;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import haxe.Timer;
import Sys;

using StringTools;

// @:nullSafety
class Main {
	@:noCompletion inline static var __filename:String = "./libraries.xml";
	@:noCompletion inline static var __silent:Bool = false;

	public static function main() : Void {
		final args:Array<String> = Sys.args();
		final __skip:Bool = args.length > 0 && args[0] == "--auto-exit" ? true : false;

		var libraries:Array<TLibrary> = [];

		Console.separator("Lunar Engine Setup 🌒");
		if (!FileSystem.exists('.haxelib')) FileSystem.createDirectory('.haxelib');

		if (!FileSystem.exists(__filename)) {
			Console.error('Cannot find libraries.xml file at "${__filename}"');
			return;
		}

		Console.spinner("Preparing installation...", 1.2);
		Console.success("Ready to install libraries");
		Console.success("Parsing "+__filename);

		var __libraryXML:Access = new Access(Xml.parse(File.getContent(__filename)).firstElement());

		for (libNode in __libraryXML.elements) {
			var lib:TLibrary = {
				name: libNode.att.name,
				type: libNode.name,
				skipDeps: libNode.has.skipDeps && libNode.att.skipDeps == "true"
			};

			if (libNode.has.global) lib.global = libNode.att.global;

			switch (lib.type) {
				case "lib":
					if (libNode.has.version) lib.version = libNode.att.version;
				case "git":
					if (libNode.has.url) lib.url = libNode.att.url;
					if (libNode.has.ref) lib.ref = libNode.att.ref;
			}
			libraries.push(lib);
		}
		Console.success("Finished parsing "+__filename+", found " + libraries.length + " libraries to install");

		Console.separator("Installing libraries");
		for (lib in libraries) {
			Sys.println('\n');
			var __globalLib:Null<Null<String>> = lib.global == "true" ? "--global" : null;
			switch (lib.type) {
				case "lib":
					Console.info((lib.global == "true" ? "Globally installing" : "Locally installing") + ' "${lib.name}"');
					__progressRun('haxelib', [
						"install",
						lib.name,
						lib.version != null ? lib.version : "",
						__globalLib != null ? __globalLib : "",
						lib.skipDeps ? "--skip-dependencies" : "",
						"--always",
						__silent ? "--quiet" : ""
					]);
					Console.success('Installed "${lib.name}"');
				case "git":
					Console.info((lib.global == "true" ? "Globally installing" : "Locally installing") + ' "${lib.name}" from git url "${lib.url}::${lib.ref != null ? lib.ref : "main"}"');
					__progressRun('haxelib', [
						"git",
						lib.name,
						lib.url,
						lib.ref != null ? lib.ref : "",
						__globalLib != null ? __globalLib : "",
						lib.skipDeps ? "--skip-dependencies" : "",
						"--always",
						__silent ? "--quiet" : ""
					]);
					Console.success('Installed "${lib.name}"');
				default:
					Console.error('Cannot resolve library of type "${lib.type}"');
			}
		}

		// creds to @crowplexus, @nexisdumb, 
		__installVSC(__skip);
		Console.separator("All done! 🎉");
		__exit(__skip);
	}

	/**
	 * [Description] Installs Microsoft Visual Studio Community if not already installed.
	 * @param autoExit If true, exits the program after installation.
	 * @return Void
	 */
	@:noCompletion static function __installVSC(?autoExit:Bool = false) : Void {
		if (Utils.buildTarget.toLowerCase() == "windows" && new Process('"C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe" -property catalog_productDisplayVersion').exitCode(true) == 1) {
			Console.info("Installing Microsoft Visual Studio Community (Dependency)");

			Console.spinner("Downloading Visual Studio Community...", 2.5);
			Sys.command("curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe");
			Sys.command("vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p");

			FileSystem.deleteFile("vs_Community.exe");
			if(!autoExit)
			{
				Console.warning("If this wasn't specified before you'll need to restart you device for the changes to take effect.");
				Sys.print("Do you wish to do it now [y/n]? ");
				if(Sys.stdin().readLine().toUpperCase() == "Y") Sys.command("shutdown /r /t 0 /f");
			}
		}
	}

	@:noCompletion static function __exit(?autoExit:Bool = false) : Void {
		Sys.print(Console.GREEN + "Finished installing libraries. " + Console.RESET);
		if(!autoExit) {
			Sys.print(Console.CYAN + "Exit program? (Y): " + Console.RESET);
			while (true) {
				var input:String = Sys.stdin().readLine();
				if (input == null) continue;
				input = input.trim().toUpperCase();
				if (input == "Y") break;

				Sys.print(Console.YELLOW + "Press Y To Leave: " + Console.RESET);
			}
		}
		else
			Sys.exit(0);
	}

	@:noCompletion static final __ereg:EReg = ~/(\d+)%/;

	@:access(Console.SPIN_FRAMES)
	@:noCompletion static function __progressRun(cmd:String, args:Array<String>) : Void {
		args = args != null ? args : [];
		if (args.length == 0) return;

		final __process:Process = new Process(cmd, args.filter(a -> a != null && a.length > 0));

		var __i:Int = 0;
		var __prevPercent:Null<Int> = null;

		while (true) {
			try {
				var line = __process.stdout.readLine();
				if (__ereg.match(line)) {
					final __percent:Int = Std.parseInt(__ereg.matched(1));
					if (__percent != null) __prevPercent = __percent;
				}
				if (__prevPercent != null)
					@:noCompletion Sys.print("\r" + Console.renderProgressBar(__prevPercent, Console.SPIN_FRAMES[__i % Console.SPIN_FRAMES.length]));
				__i++;
			} catch (e:Eof) 
				break;
		}

		__process.close();
		Sys.print("\r" + Console.renderProgressBar(100, "✓ ") + "\n");
	}

}