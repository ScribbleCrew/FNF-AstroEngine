package funkin.backend.client;

#if DISCORD_ALLOWED
#if WATERMARK import funkin.game.Init; #end

private enum abstract RPC_BUTTON_TYPE(String) from String to String
{
	final FIRST:String = "first";
	final SECOND:String = "second";
}

@:allow(funkin.backend.system.scripts.FunkinLua)
class DiscordClient
{
	/**
	 * has `DiscordClient` initialized.
	 */
	public static var isInitialized:Bool = false;

	@:dox(hide) static var _defaultID(default, never):String = Config.discordID;

	/**
	* An instance of `DiscordRichPresence`.
	*/
	static var presence:DiscordRichPresence = DiscordRichPresence.create();

	/**
	 * The client's user id.
	 */
	@:isVar
	public static var clientID(default, set):String;
	@:dox(hide) static inline function set_clientID(newID:String):String
	{
		if (newID == null) return clientID = _defaultID;

		final compareClientIds:Bool = (clientID != newID);
		clientID = newID;

		if (compareClientIds && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}

		return newID;
	}

	/**
	 * The client's name.
	 */
	@:isVar
	public static var clientName(default, set):String = null;
	@:dox(hide) static inline function set_clientName(value:String):String
		return clientName = value;

	/**
	 * The client's discriminator.
	 */
	@:isVar
	public static var clientDiscriminator(default, set):String = null;
	@:dox(hide) static inline function set_clientDiscriminator(value:String):String
		return clientDiscriminator = value;

	/**
	 * Check the client id.
	 * used on init.
	 */
	static inline function _checkClientID():Void
	{
		clientID = Config.discordID == '' ? cast(Constants.DEFAULT_DISCORD_ID, String) : _defaultID;
		if (ClientPrefs.data.discordRPC) initialize(); else if (isInitialized) shutdown();
	}

	/**
	 * Prepare the rpc.
	 */
	public static function prepare():Void
	{
		if (!isInitialized && ClientPrefs.data.discordRPC) initialize();
		Application.current.window.onClose.add(() -> if (isInitialized) shutdown());
	}

	public dynamic static function shutdown():Void
	{
		Discord.Shutdown();
		isInitialized = false;
	}

	static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		clientName = cast(requestPtr.username, String);
		clientDiscriminator = cast(requestPtr.discriminator, String);

		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0)
		{ // Old discriminators
			final userDiscriminator = '${cast (requestPtr.username, String)}#${cast (requestPtr.discriminator, String)}';
			#if WATERMARK Init.watermark.text += '\n$userDiscriminator'; #end
			trace('Connected to User ($userDiscriminator)');
		}
		else
		{ // New Discord IDs/Discriminator system
			final user = cast(requestPtr.username, String);
			#if WATERMARK Init.watermark.text += '\n@$user'; #end
			Logs.prefixedTrace('Connected to user ($user)', 'Discord Client', BLUE);
		}

		#if WATERMARK
		final userID = cast(requestPtr.userId, String).trim();
		trace(userID);
		Init.watermark.text += '\n$userID';
		Init.watermark.y = (FlxG.height - Init.watermark.textHeight) / 2;
		#end

		changePresence();
	}

	static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
		Logs.prefixedTrace('Error ($errorCode: ${cast (message, String)})', "Discord Client", BLUE);

	static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
		Logs.prefixedTrace('Disconnected ($errorCode: ${cast (message, String)})', "Discord Client", BLUE);

	public static function initialize():Void
	{
		#if desktop
		final discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), 1, null);

		if (!isInitialized)
			Logs.prefixedTrace('Successfully initialized', "Discord Client", BLUE);

		sys.thread.Thread.create(() ->
		{
			final localID:String = clientID;
			while (localID == clientID)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();

				Sys.sleep(1);
			}
		});

		isInitialized = true;
		#else
		FlxG.log.error('Desktop Support Only.')
		#end
	}

	public static function changePresence(?details:String = 'In the Menus', ?state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool,
			?endTimestamp:Float, largeImageKey:String = 'icon'):Void
	{
		var startTimestamp:Float = 0;
		if (hasStartTimestamp)
			startTimestamp = Date.now().getTime();
		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		presence.details = details;
		presence.state = state;
		presence.largeImageKey = largeImageKey;
		presence.largeImageText = "Engine Version: " + cast(EngineData.VERSION, String);
		presence.smallImageKey = smallImageKey;

		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);

		updatePresence();
	}

	static function updatePresence():Void
	{
		changeRPCButton(FIRST, {label: "Github Page", url: "https://github.com/ScribbleCrew"});
		changeRPCButton(SECOND, {label: "X Page", url: "https://x.com/YourFriendOrbl"});

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	static dynamic function changeRPCButton(type:RPC_BUTTON_TYPE, data:{label:String, url:String}):Void
	{
		if(Reflect.getProperty(presence, 'button${type}Label') == null)
		switch (type)
		{
			case FIRST:
				presence.button1Label??=cast(data.label, String);
				presence.button1Url ??= cast(data.url, String);
			case SECOND:
				presence.button2Label ??= cast(data.label, String);
				presence.button2Url ??= cast(data.url, String);
		}
	}

	#if MODS_ALLOWED
	public static function loadModdedRPC():Void
	{
		final pack:Dynamic = Mods.getPack();
		if (pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
			clientID = (pack.discordRPC == "863222024192262205" ? cast(Constants.DEFAULT_DISCORD_ID, String) : pack.discordRPC); // lmao, fuck psych(lies)
	}
	#end

	#if LUA_ALLOWED
	static function addLuaCallbacks(lua:State):Void
	{
		Lua_helper.add_callback(lua, "changePresence", 
			(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) ->
				changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp)
		);

		Lua_helper.add_callback(lua, "changeClientID", (?newID:String = null) -> clientID = newID ??= _defaultID);
	}
	#end
}
#end
