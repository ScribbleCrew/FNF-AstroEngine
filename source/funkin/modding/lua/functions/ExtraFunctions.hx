package funkin.modding.lua.functions;
#if LUA_ALLOWED 
import flixel.util.FlxSave;
import openfl.utils.Assets;
import haxe.crypto.*;

//
// Things to trivialize some dumb stuff like splitting strings on older Lua
//
class ExtraFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		#if WINDOW_CUSTOMIZATION
		Lua_helper.add_callback(lua, "setDarkmode", function(value:Bool)
		{
			#if windows
			Windows.darkmode = value;
			#else
			FunkinLua.luaTrace("setDarkmode: Platform unsupported for darkmode! (use windows)", false, false, FlxColor.RED);
			#end
		});
		#end

		Lua_helper.add_callback(lua, "hash", function(txt:String, type:String = "md5") return function(){
			switch (type)
			{
				case 'md5':
					return Md5.encode(txt);
				case 'sha1':
					return Sha1.encode(txt);
				case 'sha224':
					return Sha224.encode(txt);
				case 'sha256':
					return Sha256.encode(txt);
				default:
					FunkinLua.luaTrace("Unsupported hash type: " + type, false, false, FlxColor.RED);
					return null;
			}
		});

		// Keyboard & Gamepads
		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String) return FlxG.gamepads.anyJustPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String) FlxG.gamepads.anyPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String) return FlxG.gamepads.anyJustReleased(name));

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String = '')
		{
			name = name.toLowerCase().trim();
			switch (name)
			{
				case 'left':
					return PlayState.instance.controls.NOTE_LEFT_P;
				case 'down':
					return PlayState.instance.controls.NOTE_DOWN_P;
				case 'up':
					return PlayState.instance.controls.NOTE_UP_P;
				case 'right':
					return PlayState.instance.controls.NOTE_RIGHT_P;
				default:
					return PlayState.instance.controls.justPressed(name);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String = '')
		{
			name = name.toLowerCase().trim();
			switch (name)
			{
				case 'left':
					return PlayState.instance.controls.NOTE_LEFT;
				case 'down':
					return PlayState.instance.controls.NOTE_DOWN;
				case 'up':
					return PlayState.instance.controls.NOTE_UP;
				case 'right':
					return PlayState.instance.controls.NOTE_RIGHT;
				default:
					return PlayState.instance.controls.pressed(name);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String = '')
		{
			name = name.toLowerCase().trim();
			switch (name)
			{
				case 'left':
					return PlayState.instance.controls.NOTE_LEFT_R;
				case 'down':
					return PlayState.instance.controls.NOTE_DOWN_R;
				case 'up':
					return PlayState.instance.controls.NOTE_UP_R;
				case 'right':
					return PlayState.instance.controls.NOTE_RIGHT_R;
				default:
					return PlayState.instance.controls.justReleased(name);
			}
			return false;
		});

		// String tools
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String)
		{
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String)
		{
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String)
		{
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String)
		{
			return str.trim();
		});

		// Randomization
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '')
		{
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '')
					break;
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '')
		{
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '')
					break;
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50)
		{
			return FlxG.random.bool(chance);
		});
	}
}

#end