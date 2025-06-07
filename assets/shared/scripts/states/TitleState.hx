package states;

function update(elapsed:Float) :Void {
    if(FlxG.keys.pressed.SIX && FlxG.keys.pressed.NINE)//y'all goofy af
        trace('sex');

    if (FlxG.keys.justPressed.SEVEN)
        MusicBeatState.switchState(null, "VeryFuniState", [new TitleState()]);
}