@:final class Constants
{
	public static inline final NOTE_SUSTAIN_SIZE:Int = 44;

	public static inline final DEFAULT_LOGS_PREFIX:String = "System";

	public static inline final MODS_LIST_FILE:String = "modsList.txt";

	public static inline final DEFAULT_DISCORD_ID:String = "1095422496473358356";
	
	public static inline final SOUND_EXT:String = #if web "mp3" #else "ogg" #end;
	public static inline final VIDEO_EXT:String = "mp4";

	public static inline final DEFAULT_CHARACTER:String = 'bf'; // if the character is missing.

	public static var DEFAULT_FONT(get, null):String;
	@:noCompletion private inline static function get_DEFAULT_FONT():String
		return DEFAULT_FONT == null ? funkin.backend.utils.Paths.font("vcr.ttf") : DEFAULT_FONT;
}
