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