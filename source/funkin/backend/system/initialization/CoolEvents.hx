package funkin.backend.system.initialization;

class CoolEvents
{
    @:allow(funkin.game.Main)
	static function init() : Void
	{
		FlxG.signals.focusLost.add(() -> FlxG.sound.volume *= 1);
		FlxG.signals.focusGained.add(() -> FlxG.sound.volume /= 1);

		Application.current.onExit.add((brah)->{
            #if hxvlc hxvlc.util.Handle.dispose(); #end
            #if DISCORD_ALLOWED DiscordClient.shutdown(); #end
            FlxG.save.close();
        });
	}
}
