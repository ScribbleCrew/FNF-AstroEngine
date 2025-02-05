package funkin.backend.data;

@:publicFields
final class EngineData
{
	static final VERSION:String = '0.3.0';
	static final REPOSITORY:String = 'https://github.com/ScribbleCrew/FNF-AstroEngine/';
	static final MENU_COLOR:Int = 0xff525252;

	public function new()
	{
		if (funkin.backend.utils.ClientPrefs.data.lowQuality)
			funkin.backend.utils.ClientPrefs.data.mouseEvents = false;
	}
}
