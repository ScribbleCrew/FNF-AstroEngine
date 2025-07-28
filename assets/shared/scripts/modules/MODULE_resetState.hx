// This works along side the globalscript refreshing
// was `justPressed` changed to `justReleased` for da funs
#if debug function update(elapsed:Float) : Void { if (flixel.FlxG.keys.justPressed.F5) flixel.FlxG.resetState(); } #end