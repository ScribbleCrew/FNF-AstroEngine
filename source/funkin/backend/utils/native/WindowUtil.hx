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
		::funkin::game::Main_obj::audioDisconnected = true;
		return S_OK;
	};
};

AudioFixClient *curAudioFix;
')
#end
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
	@:noCompletion private static function set_darkmode(enable:Bool):Bool
	{
		if (!OsAPI.hasVersion('Windows 11'))
			refreshWindow();
		trace('${enable ? 'enabled' : 'disabled'} darkmode');
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
	public static function refreshWindow():Void
	{
		Application.current.window.width += 1;
		Application.current.window.width -= 1;
		/**
			Application.current.window.borderless = true;
			Application.current.window.borderless = false;
		**/
	}

	/**
	 *	Change the title.
	 */
	public static function setTitle(?title:String, ?normal:Bool = true):String
	{
		var titleChange:String = null;
		if (title != null)
			titleChange = (normal ? '${Application.current.meta.get('name')} - ' : '') + title;
		return Application.current.window.title = titleChange ?? Application.current.meta.get('name');
	}

	/**
	 *	Reset the title.
	 */
	public static function resetTitle():String
		return Application.current.window.title = Application.current.meta.get('name');

	/**
	 * Can be used to check if your using a specific version of an OS (or if your using a certain OS).
	 */
	#if windows
	@:functionCode(' if (!curAudioFix) curAudioFix = new AudioFixClient(); ')
	#end
	public static function registerAudio():Void
		Main.audioDisconnected = false;
}
