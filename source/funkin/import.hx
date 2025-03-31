#if !macro 
// Game
import funkin.game.Main;
import funkin.game.Config;

import funkin.game.objects.characters.*;
import funkin.game.objects.*;
import funkin.game.objects.options.*;
import funkin.game.states.*;
import funkin.game.editors.*;
import funkin.game.transitions.*;
import funkin.game.objects.notes.*;
// stage stuff
import funkin.game.objects.stages.objects.*;
import funkin.game.objects.stages.objects.weekend1.*;

import funkin.game.objects.options.*;
import funkin.game.transitions.*;
import funkin.game.objects.characters.*;
import funkin.game.objects.options.*;
import funkin.game.editors.content.*;

import funkin.game.states.substates.*;

import funkin.game.states.options.*;
import funkin.game.states.options.substates.*;

import funkin.game.states.editors.*;
import funkin.game.states.editors.substates.*;

import funkin.game.objects.shaders.*;
import funkin.game.objects.scorebars.*;
import funkin.game.objects.stages.*;
import funkin.game.objects.mods.*;
import funkin.game.objects.notes.Note.EventNote;
import funkin.game.objects.shaders.RGBPalette.RGBShaderReference;

// backend
import funkin.backend.macro.*;
import funkin.backend.system.*;
import funkin.backend.utils.*;
import funkin.backend.data.*;
import funkin.backend.*;
import funkin.backend.Prompt;
import funkin.backend.Achievements.Achievement;
import funkin.backend.base.*;
import funkin.backend.audio.*;
import funkin.backend.utils.native.*;
import funkin.backend.base.BaseStage.Countdown;
import funkin.backend.system.ui.*;
import funkin.backend.handlers.*;
import funkin.backend.objects.*;
import funkin.backend.objects.editers.*;
import funkin.backend.objects.editers.VSlice;
import funkin.backend.animation.*;
import funkin.backend.Song.SwagSong;
import funkin.backend.Song.SwagSection;
import funkin.backend.data.StageData.StageFile;
#if MODIFIED_LOGS import funkin.backend.system.initialization.Logs; #end

// Haxe
import haxe.extern.*;

//Discord API
#if DISCORD_ALLOWED import funkin.backend.client.Discord; #end

// Lua
import funkin.backend.system.scripts.*;
import funkin.backend.system.scripts.luaStuff.*;
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

// FlxAnimate
#if FLXANIMATE_ALLOWED
import flxanimate.*;
import funkin.backend.animation.FlxAnimate;
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
#if THREADING_ALLOWED
import sys.thread.Thread;
import sys.thread.Mutex;
#end
#end

// HSCRIPT
#if HSCRIPT_ALLOWED
import funkin.backend.system.scripts.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

// Discord
#if DISCORD_ALLOWED
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end

// Haxe
import haxe.*;
import haxe.std.MathsAddon;// maths addon!!!!
using haxe.std.ArrayTools;

// Lime
import lime.app.Application;

//Openfl
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;

// Flixel
import flixel.*;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.*;
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
