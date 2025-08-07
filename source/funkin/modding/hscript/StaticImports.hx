package funkin.modding.hscript;

class StaticImports
{

    #if SOFTCODED_STATES
    static function closeSubstate(){
        if (FlxG.state != null && FlxG.state.subState != null)
				FlxG.state.subState.close();
    }
    #end

	public static var defaultVariables(get, never):Map<String, Dynamic>;
	@:dox(hide) inline static function get_defaultVariables():Map<String, Dynamic>
	{
		return [
			// Haxe Stuffz
			'Type' => Type,
			'Main' => funkin.game.Main,
			'StringTools' => StringTools,
			'Constants' => Constants, // :p
			#if sys 'File' => File, 'FileSystem' => FileSystem, #end

			// Flixel-Specific Stuff
			'FlxG' => flixel.FlxG,
			'FlxMath' => flixel.math.FlxMath,
			'FlxSprite' => flixel.FlxSprite,
			'FlxText' => flixel.text.FlxText,
			'FlxDestroyUtil' => flixel.util.FlxDestroyUtil,
			'FlxTimer' => flixel.util.FlxTimer,
			'FlxTween' => flixel.tweens.FlxTween,
			'FlxEase' => flixel.tweens.FlxEase,
			'FlxGroup' => FlxTypedGroup,
			#if (!flash && sys) 'FlxRuntimeShader' => flixel.addons.display.FlxRuntimeShader, #end

			// OpenFL-Specific Stuff
			'ShaderFilter' => openfl.filters.ShaderFilter,

			// Cameras
			'FlxCamera' => flixel.FlxCamera,
			'PsychCamera' => CustomCamera,
			'CustomCamera' => CustomCamera,
			'AstroCamera' => CustomCamera,

			// States
			'FlxState' => FlxState,
			'MusicBeatState' => MusicBeatState,
			'MusicBeatSubstate' => MusicBeatSubstate,
			'TitleState' => TitleState,

			// Game-specific
			'FunkinText' => funkin.game.objects.FunkinText,
			'Countdown' => funkin.backend.base.BaseStage.Countdown,
			'PlayState' => PlayState,
			'Paths' => Paths,
			'CoolUtil' => CoolUtil,
			'BGSprite' => BGSprite,
			'Conductor' => Conductor,
			'ClientPrefs' => ClientPrefs,
			'Windows' => funkin.backend.utils.native.Windows,
			'Character' => Character,
			'Alphabet' => Alphabet,
			'CharacterScript' => HScriptUtils.fromMacro("funkin.game.objects.characters.CharacterScript"), // :p
			'Note' => Note,
			'Logs' => Logs,
			'CustomSubstate' => CustomSubstate,
			'FlxAnimate' => FlxAnimate,
			#if ACHIEVEMENTS_ALLOWED 'Achievements' => Achievements, #end
			#if SOFTCODED_STATES 'close' => closeSubstate, 'closeSub' => closeSubstate, #end

			// Functions & Variables
			'setVar' => (name:String, value:Dynamic) ->
			{
				MusicBeatState.getVariables().set(name, value);
				return value;
			},
			'getVar' => (name:String) ->
			{
				var result:Dynamic = null;
				if (MusicBeatState.getVariables().exists(name))
					result = MusicBeatState.getVariables().get(name);
				return result;
			},
			'removeVar' => (name:String) ->
			{
				if (MusicBeatState.getVariables().exists(name))
				{
					MusicBeatState.getVariables().remove(name);
					return true;
				}
				return false;
			},
			'debugPrint' => (text:String, ?color:FlxColor = null) ->
			{
				if (color == null)
					color = FlxColor.WHITE;
				PlayState.instance.addTextToDebug(text, color);
			},

			// Keyboard & Gamepads
			'keyboardJustPressed' => (name:String) -> return Reflect.getProperty(FlxG.keys.justPressed, name),
			'keyboardPressed' => (name:String) -> return Reflect.getProperty(FlxG.keys.pressed, name),
			'keyboardReleased' => (name:String) -> return Reflect.getProperty(FlxG.keys.justReleased, name),

			'anyGamepadJustPressed' => (name:String) -> return FlxG.gamepads.anyJustPressed(name),
			'anyGamepadPressed' => (name:String) -> FlxG.gamepads.anyPressed(name),
			'anyGamepadReleased' => (name:String) -> return FlxG.gamepads.anyJustReleased(name),

			'gamepadAnalogX' => (id:Int, ?leftStick:Bool = true) ->
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return 0.0;

				return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
			},
			'gamepadAnalogY' => (id:Int, ?leftStick:Bool = true) ->
			{
				final controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return 0.0;
				return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
			},

			'gamepadJustPressed' => (id:Int, name:String) ->
			{ // find a better way :(
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;

				return Reflect.getProperty(controller.justPressed, name) == true;
			},
			'gamepadPressed' => (id:Int, name:String) ->
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;

				return Reflect.getProperty(controller.pressed, name) == true;
			},
			'gamepadReleased' => (id:Int, name:String) ->
			{
				var controller = FlxG.gamepads.getByID(id);
				if (controller == null)
					return false;

				return Reflect.getProperty(controller.justReleased, name) == true;
			},
			'keyJustPressed' => (name:String = '') ->
			{
				name = name.toLowerCase();
				switch (name)
				{
					case 'left':
						return Controls.instance.NOTE_LEFT_P;
					case 'down':
						return Controls.instance.NOTE_DOWN_P;
					case 'up':
						return Controls.instance.NOTE_UP_P;
					case 'right':
						return Controls.instance.NOTE_RIGHT_P;
					default:
						return Controls.instance.justPressed(name);
				}
				return false;
			},

			'keyPressed' => (name:String = '') ->
			{
				name = name.toLowerCase();
				switch (name)
				{
					case 'left':
						return Controls.instance.NOTE_LEFT;
					case 'down':
						return Controls.instance.NOTE_DOWN;
					case 'up':
						return Controls.instance.NOTE_UP;
					case 'right':
						return Controls.instance.NOTE_RIGHT;
					default:
						return Controls.instance.pressed(name);
				}
				return false;
			},
			'keyReleased' => (name:String = '') ->
			{
				name = name.toLowerCase();

				switch (name)
				{
					case 'left':
						return Controls.instance.NOTE_LEFT_R;
					case 'down':
						return Controls.instance.NOTE_DOWN_R;
					case 'up':
						return Controls.instance.NOTE_UP_R;
					case 'right':
						return Controls.instance.NOTE_RIGHT_R;
					default:
						return Controls.instance.justReleased(name);
				}

				return false;
			},

			#if LUA_ALLOWED
			// For adding your own callbacks
			// not very tested but should work
			'createGlobalCallback' => (name:String, func:Dynamic) ->
			{
				for (script in FunkinLua.instances)
					if (script != null && script.lua != null && !script.closed)
						Lua_helper.add_callback(script.lua, name, func);

				FunkinLua.customFunctions.set(name, func);
			}, // this one was tested
			#end

			// PLAYSTATE STUFF
			'setDefaultGF' => (name:String) ->
			{
				if (PlayState.instance == null)
				{
					FlxG.log.warn('{HScript.setDefaultGF}: This isn\'t allowed in current state');
					return null;
				}
				var gfVersion:String = PlayState.SONG.gfVersion;
				if (gfVersion == null || gfVersion.length < 1)
				{
					gfVersion = name;
					PlayState.SONG.gfVersion = gfVersion;
				}
			},
			'addHxObject' => (obj:FlxObject, front:Bool = false) ->
			{ // stolen from FunkinLua
				if (PlayState.instance == null)
				{
					FlxG.log.warn('{HScript.addHxObject}: This isn\'t allowed in current state');
					return null;
				}

				if (obj == null)
					return false;

				var instance = LuaUtils.getTargetInstance();
				if (front)
					instance.add(obj);
				else
				{
					(PlayState.instance == null || !PlayState.instance.isDead) ? instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()),
						obj) : GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
				}
				return true;
			},
			//////////////////////////////////////////////////////

			'state' => FlxG.state,
			'controls' => Controls.instance,

			'buildTarget' => LuaUtils.getBuildTarget(),
			'customSubstate' => CustomSubstate.instance,
			'customSubstateName' => CustomSubstate.name,

			'Function_Stop' => Function_Stop,
			'Function_Continue' => Function_Continue,
			'Function_StopLua' => Function_StopLua, // doesnt do much cuz HScript has a lower priority than Lua
			'Function_StopHScript' => Function_StopHScript,
			'Function_StopAll' => Function_StopAll,
		];
	}

    static function init(){
        for (i => j in StaticImports.defaultVariables)
			RuleScript.defaultImports.get('').set(i, j);
    }
}
