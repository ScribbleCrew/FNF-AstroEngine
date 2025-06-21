package funkin.backend.data;

class EngineData
{
	public static final VERSION:String = '0.3.0';
	public static final REPOSITORY:String = 'https://github.com/ScribbleCrew/FNF-AstroEngine/';
	public static final MENU_COLOR:Int = 0xff525252;

	public function new()
	{
		if (funkin.backend.utils.ClientPrefs.data.lowQuality)
			funkin.backend.utils.ClientPrefs.data.mouseEvents = false;
	}
}
