package funkin.backend.utils.native;

import haxe.crypto.Md5;

class OsAPI
{
	public static var username(get, null):String;
	public static var hashUsernameMD5(get, null):String;
	public static var osInfo(get, never):String;
	public static var osVersion(get, never):String;

	@:noCompletion private inline static function get_username()
	{
		final environment = Sys.environment();

		if (environment.exists("USERNAME"))
			return environment["USERNAME"];
		if (environment.exists("USER"))
			return environment["USER"];

		return '???';
	}

	private static function get_osInfo()
	{ // stolen from twist engine lmao
		if (lime.system.System.platformLabel != null
			&& lime.system.System.platformLabel != ""
			&& lime.system.System.platformVersion != null
			&& lime.system.System.platformVersion != "")
			return lime.system.System.platformLabel.replace(lime.system.System.platformVersion, "").trim();
		else
			trace('Unable to grab OS Label');

		return null;
	}

	private static inline function get_osVersion()
		return lime.system.System.platformVersion;

	@:noCompletion private inline static function get_hashUsernameMD5()
		return HashUtils.hash(username, MD5);
}
