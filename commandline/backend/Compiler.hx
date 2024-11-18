package backend;

class Compiler
{
	public static function test(args:Array<String>)
		__build(args, ["test", getBuildTarget()]);

	public static function build(args:Array<String>)
		__build(args, ["build", getBuildTarget()]);

	public static function release(args:Array<String>)
		__build(args, ["build", getBuildTarget()]);

	public static function testRelease(args:Array<String>)
		__build(args, ["test", getBuildTarget()]);

	public static inline function getBuildTarget():String
		{
			return switch (Sys.systemName())
			{
				case "Windows" | "Linux":
					Sys.systemName().toLowerCase();
				case "Mac":
					"macos";
				case def:
					def.toLowerCase();
			}
		}

	/**
	 * i genuinely don't know how im meant to explain this - orbl
	 * @param args List of agurments.
	 * @param arg A array which contains args.
	 */
	@:noCompletion private static function __build(args:Array<String>, arg:Array<String>)
	{
		for (i in args)
			arg.push(i);
		Sys.command("lime", arg);
	}
}
