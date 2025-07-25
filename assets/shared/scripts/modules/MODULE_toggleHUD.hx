// hides every camera except the first one also known as array place number 0
// im really bad at explaining, sorry. :(

var cooldown:Float = 0;
var toggle:Bool = true;
var prevToggle:Bool = toggle;

function update(elapsed:Float):Void
{
	cooldown -= elapsed;

	if (FlxG.keys.justPressed.F4 && cooldown <= 0)
	{
		cooldown = .1;
		toggle = !toggle;
	}

    if (Main.framerateCounter != null)
        Main.framerateCounter.visible = toggle;
    for (i => v in FlxG.cameras.list)
    {
        if (i == 0) continue;
        if (v != null) v.visible = toggle;
    }
    prevToggle = toggle;
}
