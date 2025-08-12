./readme.md

# Information:

- Sadly, lua isn't supported.

---

### HScript Example:

```haxe
package huds;

import flixel.util.FlxColor;
import funkin.backend.base.UserInterface;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextAlign;
import funkin.backend.utils.Paths;

using funkin.backend.utils.StringUtils;  // for the substitute function

class Psych extends UserInterface
{
	override function create():Void
	{
		scoreText = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 1.25;
		scoreText.visible = !ClientPrefs.data.hideHud;
		scoreText.alpha = 0;
		scoreText.setFormat(Constants.DEFAULT_FONT, 20, FlxColor.WHITE, FlxTextAlign.CENTER, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreText);
	}

	override function updateScore():Void
	{
		scoreText.text = 'Score: {1} | Misses: {2} | Rating: {3}'.substitute([
			game.songScore,
			game.songMisses,
			game.formattedRating
		]);
	}
}
```

reference stolen from [`Psych.hx`](./Psych.hx)
