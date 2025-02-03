package funkin.backend.utils.native;

class OsAPI
{
	@:isVar
	public static var username(get, null):String;
	@:noCompletion private inline static function get_username()
	{
		final environment = Sys.environment();

		if (environment.exists("USERNAME"))
			return environment["USERNAME"];
		if (environment.exists("USER"))
			return environment["USER"];

		return '???';
	}

	@:isVar
	@:deprecated("useless, going soon. -orbl")
	public static var hashUsernameMD5(get, null):String;
	@:noCompletion private inline static function get_hashUsernameMD5()
		return HashUtils.hash(username, MD5);

	/**
	 * Os Version
	 */
	@:isVar
	public static var osVersion(get, never):String;
	@:noCompletion private static inline function get_osVersion()
		return lime.system.System.platformVersion;

	/**
	 * Os Information / Platform Label exmp: 
	 */
	@:isVar
	public static var osInfo(get, never):String;
	@:noCompletion private static function get_osInfo()
	{
		if (lime.system.System.platformLabel != null
			&& lime.system.System.platformLabel != ""
			&& lime.system.System.platformVersion != null
			&& lime.system.System.platformVersion != "")
			return lime.system.System.platformLabel.replace(lime.system.System.platformVersion, "").trim();
		else
			throw 'Unable to grab OS Label';

		return null;
	}

	/**
	 * Checking is the user has a specific os version, thingy. Sowwy~ i don't wat i was owo thinking :3c
	 */
	public static function hasVersion(index:String)
		return osVersion.toLowerCase().indexOf(index.toLowerCase()) != -1;
}
