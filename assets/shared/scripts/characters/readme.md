./readme.md

# Information:

- Character scripts can be made using Lua or Haxe.

---

## Examples:

### HScript:

- `instance` is the character the script is running for.
- `registerCharacterObject` allows the objects to be tracked.
  
```haxe
package character;

import funkin.game.objects.characters.CharacterScript;
import flixel.addons.effects.FlxTrail;

class Spirit extends CharacterScript
{
	// VARIABLE
	var foo:FlxTrail = null;

	/** 
	 * POST FUNCTION
	 * The function is ran after `new()`
	 * i wouldn't recommend creating objects that depend on `instance`(the character)
	 */
	override function post():Void
	{
		trail = new FlxTrail(instance, null, 4, 24, 0.3, 0.069);
		final registeredTrail = registerCharacterObject(trail);
		game.addBehindDad(registeredTrail);

		instance.setPosition(FlxG.width - instance.x, FlxG.height - instance.y);
		instance.soSOMETHING();

		// BLAH BLAH BLAH
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// UPDATE FUNCTION.
	}

	override function draw():Void
	{
		super.draw();

		// DRAW FUNCTION.
	}
}
```

### Lua (like a normal Lua script):
```lua
function onCreate()
   -- blah blah blah
end
```
