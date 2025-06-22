./readme.md

make sure refer to [`readme.md`](./readme.md)

### API:

```haxe
/**
* Astro Engine's Custom Substate Script Template. 
* ----------------------
* Avoid trying to use oop (object orientated programming) inside in any script; I don't entirely know if it's supported by hscript-iris.
* Use `CustomSubState.hx` as an example.
*
* Remember!!! Be creative ;3c
*/

// Custom Sprite.
var customSprite:FlxSprite = new FlxSprite();
customSprite.makeGraphic(100, 100, FlxColor.BLACK); 
add(customSprite);

// Constructor function, runs when creating a instance of this script.
// This function also supports augments.
function new(arg1:Dynamic, arg2:Any, arg3:Null<Float>):Void {}

// All currently supported functions.
// applies to lua as well.
close();// Haxe ONLY!!
closeSub();  // Lua & Haxe

// Close Callbacks
function onClose() : Void {}
function onClosePost() : Void {}

function create():Void {}
function createPost():Void {}
function update(elapsed:Float):Void {}
function destroy():Void {}
function beatHit():Void {}
function stepHit():Void {}
function sectionHit():Void {}
```