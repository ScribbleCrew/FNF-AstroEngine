package funkin.game.states.substates;

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;

	#if LUA_ALLOWED
	public static function implement(funk:funkin.modding.lua.FunkinLua):Void
	{
		final lua = funk.lua;
		Lua_helper.add_callback(lua, "openCustomSubstate", openCustomSubstate);
		Lua_helper.add_callback(lua, "closeCustomSubstate", closeCustomSubstate);
		Lua_helper.add_callback(lua, "insertToCustomSubstate", insertToCustomSubstate);
	}
	#end

	public static function openCustomSubstate(name:String, ?pauseGame:Bool = false):Void
	{
		if (pauseGame)
		{
			FlxG.camera.followLerp = 0;
			PlayState.instance.persistentUpdate = false;
			PlayState.instance.persistentDraw = true;
			PlayState.instance.paused = true;
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				PlayState.instance.vocals.pause();
			}
		}
		PlayState.instance.openSubState(new CustomSubstate(name));
		
		#if HSCRIPT_ALLOWED
		GlobalScript.instance.setOnHScript('customSubstate', instance);
		GlobalScript.instance.setOnHScript('customSubstateName', name);
		#end
	}

	public static function closeCustomSubstate():Bool
	{
		if (instance != null)
		{
			PlayState.instance.closeSubState();
			instance = null;
			return true;
		}
		return false;
	}

	public static function insertToCustomSubstate(tag:String, ?pos:Int = -1):Bool
	{
		if (instance != null)
		{
			var tagObject:FlxObject = cast(MusicBeatState.getVariables().get(tag), FlxObject);
			#if LUA_ALLOWED if (tagObject == null)
				tagObject = cast(MusicBeatState.getVariables().get(tag), FlxObject); #end

			if (tagObject != null)
			{
				if (pos < 0)
					instance.add(tagObject);
				else
					instance.insert(pos, tagObject);
				return true;
			}
		}
		return false;
	}

	override function create():Void
	{
		instance = this;

		GlobalScript.instance.call('onCustomSubstateCreate', [name]);
		super.create();
		GlobalScript.instance.call('onCustomSubstateCreatePost', [name]);
	}

	public function new(name:String):Void
	{
		CustomSubstate.name = name;
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void
	{
		GlobalScript.instance.call('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		GlobalScript.instance.call('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy():Void
	{
		GlobalScript.instance.call('onCustomSubstateDestroy', [name]);
		name = 'unnamed';

		#if HSCRIPT_ALLOWED
		GlobalScript.instance.setOnHScript('customSubstate', null);
		GlobalScript.instance.setOnHScript('customSubstateName', name);
		#end
		
		super.destroy();
	}
}
