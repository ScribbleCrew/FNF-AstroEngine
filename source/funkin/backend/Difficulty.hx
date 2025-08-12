package funkin.backend;

class Difficulty
{
	/**
	 * Diff list.
	 * Contains normal & mod stuff
	 */
	public static var list:Array<String> = [];

	/**
	 * The chart that has no postfix and starting difficulty on Freeplay/Story Mode	
	 */
	static var defaultDifficulty(default, never):String = 'Normal';

	/**
	 * The default diff list.
	 */
	public static var defaultList(get, never):Array<String>;
	@:noCompletion inline static function get_defaultList():Array<String>
		return ['Easy', 'Normal', 'Hard'];

	inline public static function getFilePath(num:Null<Int> = null):String
	{
		num ??= PlayState.storyDifficulty;
		return Paths.formatToSongPath(Paths.formatToSongPath(list[num]) != Paths.formatToSongPath(defaultDifficulty) ? '-' + list[num] : '');
	}

	inline public static function loadFromWeek(week:WeekData = null):Void
	{
		if (week == null)
			week = WeekData.getCurrentWeek();

		var diffStr:String = week.difficulties;
		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.trim().split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
				list = diffs;
		}
		else
			resetList();
	}

	inline public static function resetList():Void
		list = defaultList.copy();

	inline public static function copyFrom(diffs:Array<String>):Void
		list = diffs.copy();

	inline public static function getString(?num:Null<Int> = null):String
		return list[num == null ? PlayState.storyDifficulty : num];

	inline public static function getDefault():String
		return defaultDifficulty;
}
