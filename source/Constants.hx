/**
 * Constants because funny???	
 * Inlines can't be accessed during runtime?
 */
class Constants
{
	/**
	 * =========================
	 * 		GLOBAL VARIABLES
	 * =========================
	 */

	/**
	 * Default character
	 */
	public static final DEFAULT_CHARACTER:String = 'bf'; // if the character is missing.

	/**
	 * Note sustain size.	
	 */
	public static final NOTE_SUSTAIN_SIZE:Int = 44;

	/**
	 * Friday Night Funkin's Classic Player Strumline Offset X axes.
	 */
	public static final CLASSIC_STRUMLINE_X_OFFSET:Float = 48;

	/**
	 * Default log prefix.
	 */
	public static inline final DEFAULT_LOGS_PREFIX:String = "System";

	/**
	 * Mods list file.
	 */
	public static inline final MODS_LIST_FILE:String = "modsList.txt";

	/**
	 * Default engine discord id.
	 */
	public static inline final DEFAULT_DISCORD_ID:String = "1095422496473358356";

	public static inline final DEFAULT_SUSTAIN_COVER:String = "holdCovers/holdCover";

	/**
	 * =========================
	 * 		FILE EXTENSIONS
	 * =========================
	 */
	/**
	 * Sound file extension.
	 */
	public static inline final SOUND_EXT:String = #if web "mp3" #else "ogg" #end;

	/**
	 * Image file extension.	
	 */
	public static inline final IMAGE_EXT:String = ".png";

	/**
	 * Video file extension.
	 */
	public static inline final VIDEO_EXT:String = "mp4";

	/**
	 * =========================
	 * 		CHARTING STATE
	 * =========================
	 */
	/**
	 * Show the event column in teh chart editor...	
	 */
	public static inline final SHOW_EVENT_COLUMN:Bool = true;

	/**
	 * Show many grid columns per player	.
	 */
	public static inline final GRID_COLUMNS_PER_PLAYER:Int = 4;

	/**
	 * The amount of players on the grid.	
	 */
	public static inline final GRID_PLAYERS:Int = 2;

	/**
	 * The grid's size expressed in pixels.	
	 */
	public static inline final GRID_SIZE:Int = 40;

	/**
	 * =========================
	 * 			FONTS
	 * =========================
	 */

	/**
	 * Friday Night Funkin's Default Font.
	 */
	public static var DEFAULT_FONT(get, null):String;
	@:dox(hide) @:noCompletion inline static function get_DEFAULT_FONT():String
		return DEFAULT_FONT == null ? DEFAULT_FONT = funkin.backend.utils.Paths.font("vcr.ttf") : DEFAULT_FONT;

	/**
	 * Engine's Default Font.
	 */
	public static var DEFAULT_ENGINE_FONT(get, null):String;
	@:dox(hide) @:noCompletion inline static function get_DEFAULT_ENGINE_FONT():String
		return DEFAULT_ENGINE_FONT == null ? DEFAULT_ENGINE_FONT = funkin.backend.utils.Paths.font("PhantomMuff.ttf") : DEFAULT_ENGINE_FONT;
}
