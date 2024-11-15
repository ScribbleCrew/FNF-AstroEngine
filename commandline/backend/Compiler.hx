package backend;

class Compiler {
	public static function test(args:Array<String>) {
		__build(args, ["test", getBuildTarget(), "-D", "TEST_BUILD"]);
	}
	public static function build(args:Array<String>) {
		__build(args, ["build", getBuildTarget(), "-D", "TEST_BUILD"]);
	}
	public static function release(args:Array<String>) {
		__build(args, ["build", getBuildTarget()]);
	}
	public static function testRelease(args:Array<String>) {
		__build(args, ["test", getBuildTarget()]);
	}

	/**
	 * i genuinely don't know how im meant to explain this - orbl
	 * @param args Args
	 * @param arg Arg	
	 */
	private static function __build(args:Array<String>, arg:Array<String>) {
		for(a in args)
			arg.push(a);
		Sys.command("lime", arg);
	}

	public static function getBuildTarget() {
		return switch(Sys.systemName()) {
			case "Windows" | "Linux":
				Sys.systemName().toLowerCase();
			case "Mac":
				"macos";
			case def:
				def.toLowerCase();
		}
	}
}