package funkin.backend.utils.native;

import lime.app.Application;

#if windows
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="ole32.lib" if="windows" />
</target>
')
@:cppFileCode('
#include "mmdeviceapi.h"
#include <dwmapi.h>

#define SAFE_RELEASE(punk)  \\
			  if ((punk) != NULL)  \\
				{ (punk)->Release(); (punk) = NULL; }

static long lastDefId = 0;

class AudioFixClient : public IMMNotificationClient {
	LONG _cRef;
	IMMDeviceEnumerator *_pEnumerator;

	public:
	AudioFixClient() :
		_cRef(1),
		_pEnumerator(NULL)
	{
		HRESULT result = CoCreateInstance(__uuidof(MMDeviceEnumerator),
							  NULL, CLSCTX_INPROC_SERVER,
							  __uuidof(IMMDeviceEnumerator),
							  (void**)&_pEnumerator);
		if (result == S_OK) {
			_pEnumerator->RegisterEndpointNotificationCallback(this);
		}
	}

	~AudioFixClient()
	{
		SAFE_RELEASE(_pEnumerator);
	}

	ULONG STDMETHODCALLTYPE AddRef()
	{
		return InterlockedIncrement(&_cRef);
	}

	ULONG STDMETHODCALLTYPE Release()
	{
		ULONG ulRef = InterlockedDecrement(&_cRef);
		if (0 == ulRef)
		{
			delete this;
		}
		return ulRef;
	}

	HRESULT STDMETHODCALLTYPE QueryInterface(
								REFIID riid, VOID **ppvInterface)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR pwstrDeviceId)
	{
		return S_OK;
	};

	HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR pwstrDeviceId)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(
								LPCWSTR pwstrDeviceId,
								DWORD dwNewState)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(
								LPCWSTR pwstrDeviceId,
								const PROPERTYKEY key)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(
		EDataFlow flow, ERole role,
		LPCWSTR pwstrDeviceId)
	{
		::funkin::game::Main_obj::_audioDisconnected = true;
		return S_OK;
	};
};

AudioFixClient *curAudioFix;
')
#end
@:access(funkin.game.Main._audioDisconnected)
class WindowUtil
{
	/**
	 *	Set the window to darkmode.
	 *	REQUIRES: windows based system.
	 */
	#if (WINDOW_CUSTOMIZATION && windows)
	@:isVar
	public static var darkmode(default, set):Bool;

	@:functionCode('
    int darkMode = enable ? 1 : 0;
    HWND window = GetActiveWindow();
    if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)))
        DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
    ')
	@:dox(hide)
	@:noCompletion
	static function set_darkmode(enable:Bool):Bool
	{
		trace('doob');
		if (OsAPI.hasVersion('Windows 10'))
			refreshWindow();
		return darkmode = enable;
	}
	#end

	/**
	 *	Refreshes the current window;
	 *	NEEDS: hasn't been checked yet.
	 */
	#if windows
	@:functionCode('
	HWND hwnd = GetActiveWindow();
	InvalidateRect(hwnd, NULL, TRUE);
	UpdateWindow(hwnd);
	') // idk if this actually works
	#end
	public inline static function refreshWindow():Void
	{
		Application.current.window.width++;
		Application.current.window.width--;
		/**
			Application.current.window.borderless = true;
			Application.current.window.borderless = false;
		**/
	}

	/**
	 *	Title Stuff.
	 */
	@:isVar
	public static var title(default, set):String;

	@:dox(hide) @:noCompletion inline static function set_title(value:String):String
	{
		// map with all replaceable stuff.
		final replaceMap:Map<String, Dynamic> = [
			"GAME_TITLE" => Application.current.meta.get('name'),
			"GAME_VERSION" => Application.current.meta.get('version')
		];

		// for loop to apply those custom shitz
		for (id => fixed in replaceMap)
			value = value.replace('%{$id}', fixed);

		// set da title n shit.
		return Application.current.window.title = title = Std.string(value);
	}

	/**
	 * Can be used to check if your using a specific version of an OS (or if your using a certain OS).
	 */
	#if windows @:functionCode(' if (!curAudioFix) curAudioFix = new AudioFixClient(); ') #end
	public static function registerAudio():Void
		Main._audioDisconnected = false;

	#if windows
	@:functionCode("
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);
		return (allocatedRAM / 1024);
	")
	#end
	public static function getTotalRam():Float
	{
		return 0;
	}
}
