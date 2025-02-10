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
		Main.fpsVar.updateFPS = () ->
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

			Main.fpsVar.clear();
			Main.fpsVar.addLine('true' + dots);
			Main.fpsVar.addLine('Loading deez ballz' + dots);
			Main.fpsVar.addLine('meow :3c //' + dots);
		};
	}
	else
		Main.fpsVar.reset(); // default framerate lol
}
