package funkin.backend.utils.native;

import lime.app.Application;

#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
 #include <dwmapi.h>
 ')
#end
class WindowUtil
{
	/**
		Set the window to darkmode.
		REQUIRES: windows based system.
	**/
	#if (WINDOW_CUSTOMIZATION && windows)
	@:isVar
	public static var darkmode(default, set):Bool;
	@:functionCode('
    int darkMode = enable ? 1 : 0;
    HWND window = GetActiveWindow();
    if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)))
        DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
    ')
	@:noCompletion private static function set_darkmode(enable:Bool):Bool
	{
		if (!OsAPI.osInfo.contains('11')) refreshWindow();
		trace('${enable ? 'enabled' : 'disabled'} darkmode');
		return darkmode = enable;
	}
	#end

	/**
		Refreshes the current window;
		NEEDS: hasn't been checked yet.
	**/
	#if windows
	@:functionCode('
	HWND hwnd = GetActiveWindow();
	InvalidateRect(hwnd, NULL, TRUE);
	UpdateWindow(hwnd);
	') //idk if this actually works
	#end
	public static function refreshWindow() : Void {
		Application.current.window.width += 1;
		Application.current.window.width -= 1;
		/**
		Application.current.window.borderless = true;
		Application.current.window.borderless = false;
		**/
	}

	
	/**
		Change the title.
	**/
	public static function setTitle(?title:String, ?normal:Bool = true):String
	{
		var titleChange:String = null;
		if (title != null) titleChange = (normal ? '${Application.current.meta.get('name')} - ' : '') + title;
		return Application.current.window.title = titleChange ?? Application.current.meta.get('name');
	}

	/**
		Reset the title.
	**/
	public static function resetTitle():String
		return Application.current.window.title = Application.current.meta.get('name');
}