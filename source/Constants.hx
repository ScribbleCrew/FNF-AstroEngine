import funkin.backend.utils.Paths;

@:final class Constants {
	public static inline final SOUND_EXT:String = #if web "mp3" #else "ogg" #end;
	public static inline final VIDEO_EXT:String = "mp4";

	public static inline final DEFAULT_CHARACTER:String = 'bf'; // if the character is missing.

	public static var DEFAULT_FONT(get, null):String = null;
	@:noCompletion private inline static function get_DEFAULT_FONT():String {
		if (DEFAULT_FONT == null)
			DEFAULT_FONT = Paths.font("vcr.ttf");
		return DEFAULT_FONT;
	}
}