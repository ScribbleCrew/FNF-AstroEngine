package funkin.backend.data;

@:publicFields
final class EngineData
{
	//** Customization (Source Code Only) **/
	static final coreGame = {
		coreDiscordID: "1095422496473358356",
		menuColor: 0xff525252,
	}

	//** ignore this **/
	static final engineData = {
		coreVersion: '0.3.0',
		repository: "https://github.com/AstroEngineDevs/FNF-AstroEngine"
	}

	public function new()
	{
		if (funkin.backend.utils.ClientPrefs.data.lowQuality)
			funkin.backend.utils.ClientPrefs.data.mouseEvents = false;
	}
}
