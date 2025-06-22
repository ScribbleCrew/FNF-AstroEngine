./readme.md

# Information:

- You can make custom states using Haxe or Lua.
- How to open:
    - States:
        - `MusicBeatState.switchState("<CUSTOM_STATE_NAME>", [<args here>]);`
    - Substates:
        - `openSubState(new MusicBeatSubstate("<CUSTOM_SUBSTATE_NAME>", [<args here>]));`
- Any script that starts with "~" will be ignored.
```
    API(s):
        State API: `~State_API.hx`
        Substate API: `~Substate_API.hx`
```

### API:
```haxe
/**
* Astro Engine's Custom State Script Template. 
* ----------------------
* Avoid trying to use oop (object orientated programming) inside in any script; I don't entirely know if it's supported by hscript-iris.
* Use `VeryFuniState.hx` as an example.
*
* Remember!!! Be creative ;3c
*/

// Custom Sprite.
var customSprite:FlxSprite = new FlxSprite();
customSprite.makeGraphic(100, 100, FlxColor.BLACK); 
add(customSprite);

// Custom Text
var closeText:FlxText = new FlxText();
closeText.text = "Press enter/space to leave!!!";
closeText.setFormat(null, 70, FlxColor.WHITE, FlxTextAlign.CENTER);
add(closeText);
FlxTween.tween(closeText, {alpha: 1}, 0.2, {ease: FlxEase.expoOut});

// Constructor function, runs when creating a instance of this script.
// This function also supports augments.
function new(arg1:Dynamic, arg2:Any, arg3:Null<Float>):Void {}

// All currently supported functions.
// applies to lua as well.
function create():Void {}
function createPost():Void {}
function update(elapsed:Float):Void {}
function destroy():Void {}
function beatHit():Void {}
function stepHit():Void {}
function sectionHit():Void {}
```

### Lua Example ( MainMenuState.lua ):
```lua
-- You can do anything you would usually do on a normal lua script.
function onCreate()
    print('ON CREATE');
end

function onBeatHit()
    print('ON BEAT HIT')
end

function onDestroy()
    print('ON DESTROY')
end
```

# GlobalScript:

- Anything that starts with the global will be run every state change.
- Example:
    - Allowed:
        - `global.hx`
        - `globalExample.hx`
        - `global_example.hx` (preferred, doesn't make a difference though).
        - `global.example.hx` (why would you even do this?)
    - Not Allowed:
        - `exampleGlobal.hx`
        - `example_global.hx`
        - `example.global.hx`

# Allowed file extensions:

```
    Haxe (HScript):
        - *.hx
        - *.hxc
        - *.hscript

    Lua:
        - *.lua
        - *.funkinlua
```
