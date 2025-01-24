package funkin.backend.client;

import Sys.sleep;

import funkin.game.Init;
import funkin.game.Config;

import funkin.backend.data.EngineData;
import funkin.backend.utils.ClientPrefs;

import lime.app.Application;

import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

enum ButtonType
{
	FIRST;
	SECOND;
}

class DiscordClient
{
	public static var isInitialized:Bool = false;

	private static final _defaultID:String = Config.discordID;
	private static var presence:DiscordRichPresence = DiscordRichPresence.create();
	
	@:isVar
	public static var clientID(default, set):String;
	@:noCompletion private static inline function set_clientID(newID:String)
	{
		if (newID == null) return clientID = _defaultID;

		final change:Bool = (clientID != newID);
		clientID = newID;

		if (change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}

		return newID;
	}

	@:isVar
	public static var clientName(default, set):String = null;

	@:noCompletion private static inline function set_clientName(owo:String)
		return clientName = owo;

	@:isVar
	public static var clientDiscrim(default, set):String = null;

	@:noCompletion private static inline function set_clientDiscrim(owo:String)
		return clientDiscrim = owo;

	public static function check():Void
	{
		clientID = Config.discordID == '' ? cast(Constants.DEFAULT_DISCORD_ID, String) : _defaultID;
		if (ClientPrefs.data.discordRPC)
			initialize();
		else if (isInitialized)
			shutdown();
	}

	public static function prepare():Void
	{
		if (!isInitialized && ClientPrefs.data.discordRPC)
			initialize();

		Application.current.window.onClose.add(function()
		{
			if (isInitialized)
				shutdown();
		});
	}

	public dynamic static function shutdown()
	{
		Discord.Shutdown();
		isInitialized = false;
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		clientName = '${cast (requestPtr.username, String)}';
		clientDiscrim = cast(requestPtr.discriminator, String);

		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0)
		{ // Old discriminators
			final userDiscriminator = '${cast (requestPtr.username, String)}#${cast (requestPtr.discriminator, String)}';
			#if WATERMARK Init.watermark.text += '\n$userDiscriminator\n${HashUtils.hash(cast(requestPtr.username, String), MD5)}'; #end
			trace('Connected to User ($userDiscriminator)');
		}
		else
		{ // New Discord IDs/Discriminator system
			final user = cast(requestPtr.username, String);
			#if WATERMARK Init.watermark.text += '\n@$user\n${HashUtils.hash(user, MD5)}'; #end
			trace('Connected to User ($user)');
		}

		#if WATERMARK
		final userID = cast(requestPtr.userId, String).trim();
		trace(userID);
		Init.watermark.text += '\n$userID';
		Init.watermark.y = (FlxG.height - Init.watermark.textHeight) / 2;
		#end

		changePresence();
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
		trace('[Discord Client]: Error ($errorCode: ${cast (message, String)})');

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
		trace('[Discord Client]: Disconnected ($errorCode: ${cast (message, String)})');

	public static function initialize():Void
	{
		#if desktop
		final discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), 1, null);

		if (!isInitialized)
			trace('[Discord Client]: Initialized');

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
		presence.largeImageText = "Engine Version: " + cast(EngineData.engineData.coreVersion, String);
		presence.smallImageKey = smallImageKey;

		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);

		updatePresence();
	}

	public static function updatePresence():Void
	{
		setButton({label: "Github Page", url: "https://github.com/AstroEngineDevs"}, FIRST);
		setButton({label: "X Page", url: "https://x.com/YourFriendOrbl"}, SECOND);

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	public dynamic static function setButton(data:{label:String, url:String}, type:ButtonType):Void
	{
		switch (type)
		{
			case FIRST:
				if (presence.button1Label == null)
					presence.button1Label = cast(data.label, String);
				if (presence.button1Url == null)
					presence.button1Url = cast(data.url, String);
			case SECOND:
				if (presence.button2Label == null)
					presence.button2Label = cast(data.label, String);
				if (presence.button2Url == null)
					presence.button2Url = cast(data.url, String);
		}
	}

	#if MODS_ALLOWED
	public static function loadModRPC()
	{
		final pack:Dynamic = Mods.getPack();
		if (pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
			clientID = pack.discordRPC;
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "changePresence",
			function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool,
					?endTimestamp:Float) changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp));

		Lua_helper.add_callback(lua, "changeClientID", function(?newID:String = null)
		{
			if (newID == null)
				newID = _defaultID;
			clientID = newID;
		});
	}
	#end
}
