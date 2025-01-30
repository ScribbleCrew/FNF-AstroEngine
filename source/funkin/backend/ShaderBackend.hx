package funkin.backend;

@:access(funkin.backend.system.MusicBeatState)
class ShaderBackend extends flixel.system.FlxAssets.FlxShader
{ // all shaders to be added to dis thing
	public function new()
	{
		super();

		if (cast FlxG.state is MusicBeatState)
		{
			final state:Dynamic = FlxG.state;
            if(state.shaderGroup == null)
                state.shaderGroup = [];
            trace('pushed shader');
			state.shaderGroup.push(this);
		}
	}

	private function update(elapsed:Float):Void{}
}
