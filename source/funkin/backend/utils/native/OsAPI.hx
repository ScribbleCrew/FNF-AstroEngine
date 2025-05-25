package funkin.backend.utils.native;

import haxe.ds.StringMap;
import lime.system.System;
#if cpp
@:headerCode('
#include <thread>
')
#end
class OsAPI
{
	#if cpp
	/**
	 * Gets the CPU's thread count.
	 */
	@:isVar public static var cpuThreads(get, never):Int;
	@:dox(hide) inline static function get_cpuThreads():Int
		return untyped __cpp__("std::thread::hardware_concurrency()");
	#end

	@:isVar
	public static var username(get, null):String;

	@:dox(hide) @:noCompletion inline static function get_username():String
	{
		final environment:StringMap<String> = Sys.environment();
		if (environment.exists("USERNAME"))
			return environment.get("USERNAME");
		if (environment.exists("USER"))
			return environment.get("USER");
		return '???';
	}

	/**
	 * Os Version
	 */
	@:isVar
	public static var osVersion(get, never):String;

	@:dox(hide) @:noCompletion static inline function get_osVersion()
		return System.platformVersion;

	/**
	 * Os Information / Platform Label exmp: 
	 */
	@:isVar
	public static var osInfo(get, never):String;

	@:dox(hide) @:noCompletion static function get_osInfo():String
	{
		if (System.platformLabel != null
			&& System.platformLabel != ""
			&& System.platformVersion != null
			&& System.platformVersion != "")
			return System.platformLabel.replace(System.platformVersion, "").trim();
		else
			throw 'Unable to grab OS Label';

		return null;
	}

	/**
	 * Checking is the user has a specific os version, thingy. 
	 * Sowwy~ i don't wat i was owo thinking :3c
	 */
	inline public static function hasVersion(index:String):Bool
		return osInfo.toLowerCase().indexOf(index.toLowerCase()) != -1;
}
