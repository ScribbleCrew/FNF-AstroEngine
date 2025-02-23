// https://github.com/john32b/djNode/blob/64cad4de4cb596ddf2a7b2a7aa457b6fe71fdd47/source/djNode/Terminal.hx#L10
/**----------------------------------------------
 * - Terminal.hx
 * ----------------------------------------------
 * - Useful Terminal functionality wrapper
 * ----------------------------------------------
 *
 * Features:
 * ===========
 * . Printing text
 * . Text and Background Colors
 * . Manipulating the cursor
 * . Colors in Windows and Linux terminals
 * . Clearing portions of the terminal
 *
 * Notes:
 * ============
 * 	References: http://tldp.org/HOWTO/Bash-Prompt-HOWTO/
 * 				http://ascii-table.com/ansi-escape-sequences.php
 *  			http://www.termsys.demon.co.uk/vtansi.htm
 *  			http://misc.flogisoft.com/bash/tip_colors_and_formatting
 * 				http://pueblo.sourceforge.net/doc/manual/ansi_color_codes.html
 * 				https://en.wikipedia.org/wiki/ANSI_escape_code  <--
 * 				https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences <<-- Windows
 *
 *
 * 	Cursor Position :
 *
 * 		Pos (x:1,y:1) starts NOT from the top left of the terminal window,
 * 		but rather the next line of the prompt.
 * 		To GUARANTEE a (1,1) position pageDown() first.
 *
 *
 * Examples :
 * ================
 *
 * 	= Tags in Strings for inline coloring :
 *    e.g. printf("~RED~Color Red~:WHITE~White BG~!~");
 * 		   is the equivalent of:
 * 	       fg(Color.RED).print("Color Red").bg(Color.WHITE).print("White BG").reset();
 *
 ========================================================*/
package funkin.backend.utils.native;

import StringTools;

#if cs
	import cs.system.Console;
	import cs.system.ConsoleColor;
#elseif js
	// import js.Node; // TODO
#elseif cpp
	import cpp.Lib;
#elseif neko
	import neko.Lib;
#end

enum TColor
{
	BLACK;
	WHITE;
	GRAY;
	RED;
	GREEN;
	BLUE;
	YELLOW;
	CYAN;
	MAGENTA;
	DARKGRAY;
	DARKRED;
	DARKGREEN;
	DARKBLUE;
	DARKYELLOW;
	DARKCYAN;
	DARKMAGENTA;
	ORANGE;
	PINK;
	LIGHTBLUE;
	LIGHTGREEN;
	LIGHTCYAN;
	LIGHTMAGENTA;
	BROWN;
	PURPLE;
	LIME;
	TEAL;
	NAVY;
	GOLD;
	SILVER;
}


@:dce
class Terminal
{
	// ColorEnum => Actual EscapeCode
	var COLORS_FG:Map<TColor, String>;
	var COLORS_BG:Map<TColor, String>;

	// The escape Sequence can also be '\033[', or even '\e[' in linux ''
	// I am not using the escape sequence as a reference anywhere, as hard typing is faster.
	public static inline var _ESC_SEQ 		= '\x1B[';
	public static inline var _BOLD 			= '\x1B[1m';
	public static inline var _DIM 			= '\x1B[2m';
	public static inline var _UNDERL		= '\x1B[4m';
	public static inline var _BLINK 		= '\x1B[5m';
	public static inline var _HIDDEN 		= '\x1B[8m';

	public static inline var _RESET_ALL 	= '\x1B[0m';	// All Attributes off
	public static inline var _RESET_FG	 	= '\x1B[39m';	// Foreground to default
	public static inline var _RESET_BG 		= '\x1B[49m';	// Background to default
	public static inline var _RESET_BOLD 	= '\x1B[21m';
	public static inline var _RESET_DIM 	= '\x1B[22m';
	public static inline var _RESET_UNDERL	= '\x1B[24m';
	public static inline var _RESET_BLINK	= '\x1B[25m';
	public static inline var _RESET_HIDDEN	= '\x1B[28m';

	// DEV: I don't know why have it as an option, should always be enabled? No speed critical function is going to call parsetags.
	/** If true the function `parseTags` `ptag`, will fillout `PARSED_NOTAG` which is an untagged parse */
	public var ENABLE_NOTAG:Bool = false;

	/** Holds the last parseTags() Operation but without any tags. Useful for logging. Needs ENABLE_NOTAG */
	public var PARSED_NOTAG(default, null):String = "";

	public static var instance:Terminal = new Terminal();

	public static final colorsSupported:Bool = {
		var colorSupported:Bool = false;
		/* // todo?: find more methods
		#if sys
		var term = Sys.getEnv("TERM");

		if (term == "dumb") {
			colorSupported = false;
		} else {
			if (term != null)
			{
				colorSupported = ~/(?i)-256(color)?$/.match(term)
					|| ~/(?i)^screen|^xterm|^vt100|^vt220|^rxvt|color|ansi|cygwin|linux/.match(term);
			}
			else
			{
				colorSupported = Sys.getEnv("TERM_PROGRAM") == "iTerm.app"
					|| Sys.getEnv("TERM_PROGRAM") == "Apple_Terminal"
					|| Sys.getEnv("COLORTERM") != null
					|| Sys.getEnv("ANSICON") != null
					|| Sys.getEnv("ConEmuANSI") != null
					|| Sys.getEnv("WT_SESSION") != null;
			}
		}
		#end
		*/
		colorSupported = true;
		colorSupported;
	}
	//====================================================;
	// FUNCTIONS
	//====================================================;

	public function new()
	{
		COLORS_FG = [
			DARKGRAY => '\x1B[90m',
			RED => '\x1B[91m',
			GREEN => '\x1B[92m',
			YELLOW => '\x1B[93m',
			BLUE => '\x1B[94m',
			MAGENTA => '\x1B[95m',
			CYAN => '\x1B[96m',
			WHITE => '\x1B[97m',
			BLACK => '\x1B[30m',
			DARKRED => '\x1B[31m',
			DARKGREEN => '\x1B[32m',
			DARKYELLOW => '\x1B[33m',
			DARKBLUE => '\x1B[34m',
			DARKMAGENTA => '\x1B[35m',
			DARKCYAN => '\x1B[36m',
			GRAY => '\x1B[37m',
			ORANGE => '\x1B[38;5;214m',
			PINK => '\x1B[38;5;205m',
			LIGHTBLUE => '\x1B[38;5;75m',
			LIGHTGREEN => '\x1B[38;5;120m',
			LIGHTCYAN => '\x1B[38;5;51m',
			LIGHTMAGENTA => '\x1B[38;5;13m',
			BROWN => '\x1B[38;5;94m',
			PURPLE => '\x1B[38;5;129m',
			LIME => '\x1B[38;5;118m',
			TEAL => '\x1B[38;5;30m',
			NAVY => '\x1B[38;5;19m',
			GOLD => '\x1B[38;5;220m',
			SILVER => '\x1B[38;5;250m'
		];
	
		COLORS_BG = [
			DARKGRAY => '\x1B[100m',
			RED => '\x1B[101m',
			GREEN => '\x1B[102m',
			YELLOW => '\x1B[103m',
			BLUE => '\x1B[104m',
			MAGENTA => '\x1B[105m',
			CYAN => '\x1B[106m',
			WHITE => '\x1B[107m',
			BLACK => '\x1B[40m',
			DARKRED => '\x1B[41m',
			DARKGREEN => '\x1B[42m',
			DARKYELLOW => '\x1B[43m',
			DARKBLUE => '\x1B[44m',
			DARKMAGENTA => '\x1B[45m',
			DARKCYAN => '\x1B[46m',
			GRAY => '\x1B[47m',
			ORANGE => '\x1B[48;5;214m',
			PINK => '\x1B[48;5;205m',
			LIGHTBLUE => '\x1B[48;5;75m',
			LIGHTGREEN => '\x1B[48;5;120m',
			LIGHTCYAN => '\x1B[48;5;51m',
			LIGHTMAGENTA => '\x1B[48;5;13m',
			BROWN => '\x1B[48;5;94m',
			PURPLE => '\x1B[48;5;129m',
			LIME => '\x1B[48;5;118m',
			TEAL => '\x1B[48;5;30m',
			NAVY => '\x1B[48;5;19m',
			GOLD => '\x1B[48;5;220m',
			SILVER => '\x1B[48;5;250m'
		];
		

	}//---------------------------------------------------;

	/**
	   Resize the Terminal Window,
	   - Not all terminals are resizable
	   - Window default 'cmd' is resizable OK
	**/
	public function resizeTerminal(w:Int, h:Int)
	{
		Sys.command('mode con: cols=$w lines=$h');
		// print('\033[8;$h;$w');
	}//---------------------------------------------------;

	/**
	   Set the title of the terminal window
	**/
	public function setTitle(s:String)
	{
		Sys.command('title $s');
	}//---------------------------------------------------;

	/**
	 * Get Maximum Terminal window width
	 */
	public function getWidth():Int
	{
		#if cs
			return Console.WindowWidth;
		// #elseif js
		// 	return untyped(Node.process.stdout.columns);
		#else
			return 80;	//Failsafe default
		#end
	}//---------------------------------------------------;

	/**
	 * Get Maximum Terminal window height
	 */
	public function getHeight():Int
	{
		#if cs
			return Console.WindowHeight;
		// #elseif js
		// 	return untyped(Node.process.stdout.rows);
		#else
			return 25; //Failsafe default
		#end
	}//---------------------------------------------------;

	public static final attributesEreg =  ~/\x1b\[[^m]*m/g;
	/**
	 * Writes to the terminal, unformatted
	 */
	public function print(str:String):Terminal
	{
		if (!colorsSupported)
			str = attributesEreg.replace(str, "");
		#if cpp
			Lib.print(str);
		// #elseif js
		// 	Node.process.stdout.write(str);
		#else
			Sys.print(str);
		#end

		return this;
	}//---------------------------------------------------;

	/**
	 * Writes to the terminal, then changes line, unformatted
	 * DEV: Do I really need this?
	 */
	public inline function println(str:String):Terminal
	{
		return print(str + "\n");
	}//---------------------------------------------------;

	/**
	 * Sets the color of the cursor (Foreground color)
	 * @param col, If this is null, the FG is being reset.
	 */
	public function fg(?col:TColor):Terminal
	{
		if (!colorsSupported) return this;
		if (col == null) return resetFg();
		// return print("\x1B[38;2;50;200;50m"); // MMMMM do it in future (TODO)
		return print(COLORS_FG.get(col));
	}//---------------------------------------------------;

	/**
	 * Sets the color of the background
	 * @param col, If this is null, the BG is being reset.
	 */
	public function bg(?col:TColor):Terminal
	{
		if (col == null) return resetBg();
		return print(COLORS_BG.get(col));
	}//---------------------------------------------------;

	// This is mostly unused.
	public function bold():Terminal
	{
		return print(_BOLD);
	}//---------------------------------------------------;

	//--- Resets ---//
	public inline function resetFg():Terminal	{ return print(_RESET_FG); }
	public inline function resetBg():Terminal 	{ return print(_RESET_BG); }
	public inline function resetBold():Terminal	{ return print(_RESET_BOLD); }

	/**
	 * Reset all colors and styles to default.
	 */
	public inline function reset():Terminal
	{
		return print(_RESET_ALL);
		//Console.ResetColor();
		//Console.ForegroundColor = ConsoleColor.White;
	}//---------------------------------------------------;

	/**
	 * Moves the curson to the next line of the Terminal
	 */
	public inline function endl():Terminal
	{
		return print("\n");
	}//---------------------------------------------------;


	/**
	 * Cursor Control Functions
	 **/
	public inline function up(x:Int = 1):Terminal 		{ return print('\x1B[${x}A'); }
	public inline function down(x:Int = 1):Terminal 	{ return print('\x1B[${x}B'); }
	public inline function forward(x:Int = 1):Terminal  { return print('\x1B[${x}C'); }
	public inline function back(x:Int = 1):Terminal 	{ return print('\x1B[${x}D'); }

	//----------------------------------------------------;

	/**
	 * Moves the cursor to a specific X and Y position on the Terminal
	 * Starting from (1,1)
	 */
	public function move(x:Int, y:Int):Terminal
	{
		#if cs
			Console.SetCursorPosition(x, y);
			return this;
		// #elseif js
		// 	untyped(Node.process.stdout.cursorTo(x - 1, y - 1));
		// 	return this;
		#else
			return print('\x1B[${y};${x}f');
		#end
	}//---------------------------------------------------;

	/**
	   Move Relative to current position
	**/
	public function moveR(x:Int, y:Int):Terminal
	{
		// #if js
		// 	untyped(Node.process.stdout.moveCursor(x, y));
		// #else
			var c = '';
			if (x < 0) c += _ESC_SEQ + ( -x) + 'D';
			else if (x > 0) c += _ESC_SEQ + ( x ) + 'C';
			if (y < 0) c += _ESC_SEQ + ( -y) + 'A';
			else if (y > 0) c += _ESC_SEQ + ( y) + 'B';
			print(c);
		// #end

		return this;
	}//---------------------------------------------------;


	/**
	 * Stores the position of the cursor, for later use
	 * with restorePos()
	 * BUG: On Windows CMD, SAVE/RESTORE, does not consider scrolling,
	 * 		meaning, it will restore to the save exact (x,y) of terminal space
	 * 		-Use with caution-, best used on single lines
	 */
	public inline function savePos():Terminal
	{
		return print('\x1B[s');
	}//---------------------------------------------------;

	/**
	 * Restores the cursor to the position it was stored
	 * by savePos()
	 * BUG: On Windows CMD, SAVE/RESTORE, does not consider scrolling,
	 * 		meaning, it will restore to the save exact (x,y) of terminal space
	 * 		-Use with caution-, best used on single lines
	 */
	public inline function restorePos():Terminal
	{
		return print('\x1B[u');
	}//---------------------------------------------------;

	/**
	 * Scrolls the Terminal down, it doesn't erase anything.
	 * -- it just scrolls down to window height --
	 */
	public function pageDown(h:Int = 0):Terminal
	{
		if (h == 0) h = getHeight();
		print(StringTools.lpad("", "\n", h));
		return moveR(0, -h);
	}//---------------------------------------------------;

	/**
	 * Clears the next X characters from the current stored cursor rosition
	 * @param num Number of Characters to clear
	 */
	public function clearFromHere(num:Int):Terminal
	{
		savePos().print(StringTools.lpad("", " ", num));
		return restorePos();
	}//---------------------------------------------------;

	/**
	 * Clears the line the cursor is at.
	 * - Cursor position does not change !
	 * @param type 	0:Clear all forward
	 * 				1:Clear all back
	 * 				2:Clear entire line (default)
	 */
	public function clearLine(type:Int = 2):Terminal
	{
		//#if js
			// Node.process.stdout.clearLine(
			// -1 - to the left from cursor
			//  1 - to the right from cursor
			//  0 - the entire line
		//#else
			return print('\x1B[${type}K');
		//#end
	}//---------------------------------------------------;

	/**
	 * Clears the screen
	 * @param type 	0:Clear all forward
	 * 				1:Clear all back,
	 * 				2:Clear entire screen, move cursor to 1,1 (default)
	 */
	public function clearScreen(type:Int = 2):Terminal
	{
		#if cs
			Console.Clear();
			return this;
		// #elseif js
		// 	if (type > 0) move(1, 1);
		// 	untyped(Node.process.stdout.clearScreenDown());
		// 	return this;
		#else
			return print('\x1B[${type}J');
		#end
	}//---------------------------------------------------;

	public function cursorHide():Terminal
	{
		return print("\x1B[?25l");
	}//---------------------------------------------------;
	public function cursorShow():Terminal
	{
		return print("\x1B[?25h");
	}//---------------------------------------------------;


	/**
	   Print Tags. Small function name (pt)
	   Print a tagged string to the Terminal
	   @param	s
	   @return
	**/
	public function ptag(s:String):Terminal
	{
		return print(parseTags(s));
	}//---------------------------------------------------;



	/**
	   Convert a special formatted String to a new string with the escape codes built in.
	   Tags are in the form of <tag> there are no end-tags.

	   Valid tags are:
	   ---------------
	   <color> = Set foreground color : Check TColor enum
	   <:color = Set background color : Check TColor enum
	   <!> = Reset All
	   <!fg> = Reset foreground color
	   <!bg> = Reset background color
	   <bold> = Set Bold  <!bold> = Reset Bold
	   <dim> = Set Dimmed Text <!dim> = Reset Dimmed Text
	   <underl> = Set Underling <!underl> = Reset Underline
	   <blink> = Set Blink Text <!blink> = Reset Blin Text
	   <cs> = Cursor Save Pos
	   <cr> = Cursor Restore Pos

	   ---------------
	   You can put multiple tags inside a < >, separate with comma.
			e.g. "<RED,bg:WHITE,bold>This is RED text with WHITE bg<!>"

	**/
	public function parseTags(str:String):String
	{
		// Capture <not whitespace>
		var res = ~/<(\S+?)>/g.map(str, reg -> {
			var src:String = reg.matched(1);
			var prop:Array<String> = src.split(','); // All Tag Properties e.g. ['RED','bg:WHITE']
			var ret:String = ""; 	// The compiled string to replace the tag
			for (p in prop) {
				ret += switch(p) {
					case "!" : _RESET_ALL;
					case "!fg" : _RESET_FG;
					case "!bg" : _RESET_BG;
					case "bold" : _BOLD;
					case "blink" : _BLINK;
					case "dim"	: _DIM;
					case "underl" : _UNDERL;
					case "!bold" : _RESET_BOLD;
					case "!dim" : _RESET_DIM;
					case "!blink" : _RESET_BLINK;
					case "!underl" : _RESET_UNDERL;
					case "cs" : '\x1B[s';
					case "cr" : '\x1B[u';
					default :
						// Check BG
						if (p.indexOf(':') == 0) {
							try{
								COLORS_BG.get(TColor.createByName(p.split(':')[1].toUpperCase()));
							} catch (_){
								throw 'Tag Error: Color does not exist in `$src`';
								'(X)';
							}
						}else{
						// Check Col
							try{
								COLORS_FG.get(TColor.createByName(p.toUpperCase()));
							}catch (e:Dynamic){
								//throw 'Tag Error: `$src`';
								//'(X)';
								// Or should I just pass p; as normal text
								reg.matched(0);
							}
						}
				}//- switch
			}//- for loop
			return ret;
		});

		// Keep the uncolored string
		if (ENABLE_NOTAG){
			PARSED_NOTAG = ~/<(\S+?)>/g.map(str, (reg)->"");
		}
		return res;
	}//---------------------------------------------------;

	/**
	   Repeat a charac
	   @param	len
	   @param	char
	**/
	public function rep(len:Int = 40, char:String = "-"):Terminal
	{
		return print(StringTools.lpad("", char, len));
	}//---------------------------------------------------;

}//-- end class--//