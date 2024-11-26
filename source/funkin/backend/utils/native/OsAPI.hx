package funkin.backend.utils.native;

import haxe.crypto.Md5;

class OsAPI
{
	public static var username(get, null):String;

	@:noCompletion private inline static function get_username()
	{
		final environment = Sys.environment();

		if (environment.exists("USERNAME")) return environment["USERNAME"];
		if (environment.exists("USER")) return environment["USER"];

		return '???';
	}

	public static var hashUsername(get, null):String;

	@:noCompletion private inline static function get_hashUsername()
		return Md5.encode(username);
}
