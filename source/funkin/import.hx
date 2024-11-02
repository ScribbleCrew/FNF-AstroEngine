#if !macro 
// Game
import funkin.game.objects.characters.*;
import funkin.game.objects.*;
import funkin.game.options.objects.*;
import funkin.game.states.*;
import funkin.game.editors.*;
import funkin.game.transitions.*;
import funkin.game.objects.notes.*;
import funkin.game.objects.notes.Note.EventNote;
import funkin.game.objects.stages.objects.*;
import funkin.game.transitions.*;
import funkin.game.objects.characters.*;
import funkin.game.options.objects.*;
import funkin.game.editors.content.*;
import funkin.game.states.substates.*;
import funkin.game.objects.shaders.*;
import funkin.game.objects.shaders.RGBPalette;
import funkin.backend.Prompt;

// backend
import funkin.backend.macro.*;
import funkin.backend.system.*;
import funkin.backend.utils.*;
import funkin.backend.data.*;
import funkin.backend.*;
import funkin.backend.base.*;
import funkin.backend.utils.native.*;
import funkin.backend.base.BaseStage.Countdown;
import funkin.backend.ui.*;
import funkin.backend.handlers.*;
import funkin.backend.objects.*;
import funkin.backend.Structures;
import funkin.backend.objects.editers.*;
import funkin.backend.objects.editers.VSlice;
import funkin.backend.animation.*;

//Discord API
#if DISCORD_ALLOWED
import funkin.backend.client.Discord;
#end

// Lua
import funkin.backend.funkinLua.*;
import funkin.backend.funkinLua.luaStuff.*;
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

// FlxAnimate
#if FLXANIMATE_ALLOWED
import flxanimate.*;
import funkin.backend.animation.AstroFlxAnimate as FlxAnimate;
#end

// System
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

// Videos
#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
#end

// Shader
#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

// System
#if sys
import sys.FileSystem;
import sys.io.File;
#end

// Haxe
import haxe.*;

//Openfl
import openfl.utils.Assets as OpenFlAssets;

// Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxBasic;
#end
using StringTools;
using funkin.backend.utils.StringUtils;
#if !macro
using funkin.backend.utils.ObjectUtils;
#end
