package funkin.backend.utils;

enum CacheType
{
	COUNTDOWN;
	POPUPSCORE;
}

class CacheUtils
{
	public static function cache(type:CacheType = COUNTDOWN)
	{
		trace('Cached: $type');
		switch (type)
		{
			case COUNTDOWN:
				cacheCountdown();
			case POPUPSCORE:
				cachePopUpScore();
			default:
				throw 'invalid type lol :3';
		}
	}

	public static function cacheCountdown()
	{
        final introSoundsSuffix = PlayState.instance.introSoundsSuffix;
        final stageUI = PlayState.stageUI;

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch (stageUI)
		{
			case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
			case "normal": ["ready", "set", "go"];
			default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts)
			Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public static function cachePopUpScore()
	{
		final stageUI = PlayState.stageUI;

		var uiPrefix:String = '';
		var uiPostfix:String = '';
		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage)
				uiPostfix = '-pixel';
		}

		for (rating in PlayState.instance.ratingsData)
			Paths.image(uiPrefix + rating.image + uiPostfix);
		for (i in 0...10)
			Paths.image(uiPrefix + 'num' + i + uiPostfix);
	}
}
