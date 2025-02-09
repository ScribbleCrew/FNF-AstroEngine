import funkin.game.Main;
import openfl.Lib;

var either:Bool = false;
var timePassed:Float = 0;
function goodNoteHit(note)
{
	either = !either;
	if (either)
	{
		Main.fpsVar.updateFPS = function()
		{
			timePassed += Lib.getTimer() / 1000;

			var dots:String = '';
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
			Main.fpsVar.addLine('Loading deez ballz'+dots);
			Main.fpsVar.addLine('meow :3c //' +dots);
		};
	}
	else
	{
		Main.fpsVar.updateFPS = Main.fpsVar.defaultFramerateUpdate; // default framerate lol
	}
}
