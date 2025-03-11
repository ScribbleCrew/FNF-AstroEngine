// too lazy to doc. :3

import funkin.game.Main;
import openfl.Lib;

var isShowing:Bool = false;
var timePassed:Float = 0;

function goodNoteHit(note)
{
	isShowing = !isShowing;

	if (isShowing)
	{
		Main.framerateCounter.updateFPS = () ->
		{
			var dots:String = '';

			timePassed += Lib.getTimer() / 1000;
			switch (Math.floor(timePassed % 1 * 3))
			{
				case 0:
					dots = '.';
				case 1:
					dots = '..';
				case 2:
					dots = '...';
			}

			Main.framerateCounter.clear();
			Main.framerateCounter.addLine('true' + dots);
			Main.framerateCounter.addLine('Loading deez ballz' + dots);
			Main.framerateCounter.addLine('meow :3c //' + dots);
		};
	}
	else
		Main.framerateCounter.reset(); // default framerate lol
}
