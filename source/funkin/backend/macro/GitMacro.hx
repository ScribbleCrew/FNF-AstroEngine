package funkin.backend.macro;

#if GIT_ALLOWED
#if macro
import sys.io.Process;
#end

class GitMacro
{
	/**
	 * Current git commit number.
	 */
	public static var commitNumber(get, never):Int;
	@:dox(hide) static function get_commitNumber()
		return _commitNumber();

	/**
	 * Current git commit hash.
	 */
	public static var commitHash(get, never):String;
	@:dox(hide) static function get_commitHash()
		return _commitHash();

	/**
	 * Current git branch.
	 */
	public static var branch(get, never):String;
	@:dox(hide) static function get_branch()
		return _currentBranch();

	//

	@:dox(hide) @:noCompletion private static macro function _commitNumber()
	{
		#if display
		return macro $v{0};
		#else
		try
		{
			final process = new Process('git', ['rev-list', 'HEAD', '--count'], false);
			process.exitCode(true);

			return macro $v{Std.parseInt(process.stdout.readLine())};
		}
		catch (e)
		
			trace("Error getting current commit number from git: " + e);
		
		return macro $v{0} #end
	}

	@:dox(hide) @:noCompletion private static macro function _commitHash()
	{
		#if display
		return macro $v{"~"};
		#else
		try
		{
			final process = new Process('git', ['rev-parse', '--short', 'HEAD'], false);
			process.exitCode(true);

			return macro $v{process.stdout.readLine()};
		}
		catch (e)
		
			trace("Error getting current commit hash from git: " + e);
		
		return macro $v{"~"} #end
	}

	@:dox(hide) @:noCompletion private static macro function _currentBranch()
	{
		#if display
		return macro $v{""};
		#else
		try
		{
			final process = new Process("git", ["rev-parse", "--abbrev-ref", "HEAD"], false);
			process.exitCode(true);

			return macro $v{process.stdout.readLine()};
		}
		catch (e)
		
			trace("Error getting current branch from git: " + e);
		
		return macro $v{""} #end
	}
}
#end
