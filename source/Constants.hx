/**
* Constants because funny???	
* Inlines can't be accessed in runtime?
*/
@:dce final class Constants
{
	/**
	 * Note sustain size.	
	 */
	public static inline final NOTE_SUSTAIN_SIZE:Int = 44;

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
	 * Default character
	 */
	public static inline final DEFAULT_CHARACTER:String = 'bf'; // if the character is missing.

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
	 * The default font.
	 */
	public static var DEFAULT_FONT(get, null):String;

	@:dox(hide) @:noCompletion inline static function get_DEFAULT_FONT():String
		return DEFAULT_FONT == null ? funkin.backend.utils.Paths.font("vcr.ttf") : DEFAULT_FONT;
}
