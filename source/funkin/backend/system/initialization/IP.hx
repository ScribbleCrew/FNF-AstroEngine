package funkin.backend.system.initialization;

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
	@:unreflective 
	@:noCompletion 
	@:noPrivateAccess 
	static var _ip:String = "Fetch"; // ugh

    // ip...
	@:unreflective 
	public static var ip(get, never):String;
	
	@:unreflective 
	@:noCompletion 
	static function get_ip():String
		return _ip;

	public static function init(i:Int = 0):Void
	{
		if (i >= services.length) return;

		final http:Http = new Http(services[i]);
		http.onData = function(data:String):Void _ip = data.trim();
		http.onError = function(error:String):Void init(i + 1);
		http.request();
	}
}
