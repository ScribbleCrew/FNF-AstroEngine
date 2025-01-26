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
	@:noCompletion private static function set_darkmode(enable:Bool)
	{
		trace('Darkmode ${enable ? 'Enabled' : 'Disabled'}');

		if (!OsAPI.osInfo.contains('11')) refreshWindow();

		trace(enable);
		return darkmode = enable;
	}
	#end

	@:functionCode('
	HWND hwnd = GetActiveWindow();
	InvalidateRect(hwnd, NULL, TRUE);
	UpdateWindow(hwnd);
	') //idk if this actually works
	public static function refreshWindow() {}

	public static function setTitle(?title:String, ?normal:Bool = true):String
	{
		var titleChange:String = null;
		if (title != null) titleChange = (normal ? '${Application.current.meta.get('name')} - ' : '') + title;
		return Application.current.window.title = titleChange ?? Application.current.meta.get('name');
	}

	public static function resetTitle():String
		return Application.current.window.title = Application.current.meta.get('name');
}

/**
Application.current.window.borderless = true;
Application.current.window.borderless = false;
**/