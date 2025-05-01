package funkin.backend.system;

// idk why i made this.
@:unreflective class IP
{   
    // services
    static var services:Array<String> = [
		"https://checkip.amazonaws.com",
		"https://icanhazip.com",
		"https://ifconfig.me/ip",
		"https://myexternalip.com/raw",
		"https://api.ipify.org",
		"https://ipinfo.io/ip",
		"https://wtfismyip.com/text",
		"https://ipv4.icanhazip.com",
		"https://v4.ident.me",
		"https://ip.seeip.org"
	];

    // backend ip...
	@:unreflective @:noPrivateAccess static var _ip:String = "Fetch"; // ugh

    // ip...
	@:unreflective @:noUsing public static var ip(get, never):String;
	@:unreflective @:noUsing @:noCompletion static function get_ip():String
		return _ip;

	public static function init(index:Int = 0):Void
	{
		if (index >= services.length)
			return;

		final http:Http = new Http(services[index]);
		http.onData = function(data:String):Void _ip = data.trim();
		http.onError = function(error:String):Void init(index + 1);
		http.request();
	}
}
