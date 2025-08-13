package;

import haxe.Timer;
import Sys;

using StringTools;

class Console
{
	static final SPIN_FRAMES:Array<String> = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

	public static inline final RESET  = "\x1b[0m";
	public static inline final BOLD   = "\x1b[1m";
	public static inline final UNDERLINE = "\x1b[4m";
	public static inline final REVERSED  = "\x1b[7m";

	public static inline final BLACK   = "\x1b[30m";
	public static inline final RED     = "\x1b[31m";
	public static inline final GREEN   = "\x1b[32m";
	public static inline final YELLOW  = "\x1b[33m";
	public static inline final BLUE    = "\x1b[34m";
	public static inline final MAGENTA = "\x1b[35m";
	public static inline final CYAN    = "\x1b[36m";
	public static inline final WHITE   = "\x1b[37m";

	/**
	 * [Description] Prints a message to the console with a cyan arrow prefix.
	 * @param msg message to display.
	 * @return Void
	 */
	public static function info(msg:String):Void
		Sys.println(CYAN + "→ " + RESET + msg);

	/**
	 * [Description] Prints a success message to the console with a green checkmark prefix.
	 * @param msg message to display.
	 * @return Void
	 */
	public static function success(msg:String):Void
		Sys.println(GREEN + "✓ " + RESET + msg);

	/**
	 * [Description] Prints a warning message to the console with a yellow warning prefix.
	 * @param msg message to display.
	 * @return Void
	 */
	public static function warning(msg:String):Void
		Sys.println(YELLOW + "⚠ " + RESET + msg);

	/**
	 * [Description] Prints an error message to the console with a red cross prefix.
	 * @param msg message to display.
	 * @return Void
	 */
	public static function error(msg:String):Void
		Sys.println(RED + "✖ " + RESET + msg);

	/**
	 * [Description] Prints a message to the console with a cyan spinner prefix.
	 * @param msg message to display.
	 * @param duration duration in seconds to display the spinner.
	 * @return Void
	 */
	public static function spinner(msg:String, duration:Float):Void
	{
		final __startStamp = Timer.stamp();
		var __index = 0;
		while (Timer.stamp() - __startStamp < duration)
		{
			Sys.print("\r" + CYAN + SPIN_FRAMES[__index] + RESET + " " + msg);
			Sys.sleep(.08);
			__index = (__index + 1) % SPIN_FRAMES.length;
		}
		Sys.print("\r");
	}

	/**
	 * [Description] Reloads all global scripts.
	 * @param percent The percentage of the progress bar.
	 * @param frame The frame to display in the progress bar.
	 * @return String
	 */
	inline public static function renderProgressBar(percent:Int, frame:String, ?barLength:Int):String
	{
		barLength ??= 40;

		final __filledLen:Int = Math.floor(barLength * percent / 100);
		final __bar:String = "[" + StringTools.lpad("", "░", __filledLen) + StringTools.lpad("", " ", barLength - __filledLen) + "]";
		return CYAN + frame + RESET + " " + __bar + " " + percent + "%";
	}

	@:noCompletion static inline final __sepLine:String = "────────────────────────────────────────";

	/**
	 * [Description] Prints a separator line with a title.
	 * @param title The title to display in the separator.
	 * @return Void
	 */
	public inline static function separator(title:String):Void
	{
		Sys.println(CYAN + "\n" + __sepLine);
		Sys.println("  " + title);
		Sys.println(__sepLine + RESET);
	}
}
