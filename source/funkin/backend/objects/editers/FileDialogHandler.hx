package funkin.backend.objects.editers;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;

import haxe.Exception;
#if sys
import sys.io.File;
#end
import lime.ui.*;

import flixel.FlxBasic;

//Currently only supports OPEN and SAVE, might change that in the future, who knows
@:access(funkin.backend.objects.editers.FileReferenceCustom)
class FileDialogHandler extends FlxBasic
{
	var _fileRef:FileReferenceCustom;
	var _dialogMode:FileDialogType = OPEN;
	public function new()
	{
		_fileRef = new FileReferenceCustom();
		_fileRef.addEventListener(Event.CANCEL, onCancelFn);
		_fileRef.addEventListener(IOErrorEvent.IO_ERROR, onErrorFn);

		super();
	}

	// callbacks
	public var onComplete:Void->Void;
	public var onCancel:Void->Void;
	public var onError:Void->Void;

	var _currentEvent:openfl.events.Event->Void;

	public function save(?fileName:String = '', ?dataToSave:String = '', ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void)
	{
		if(!completed)
		{
			throw new Exception('You must finish previous operation before starting a new one.');
		}

		this._dialogMode = SAVE;
		_startUp(onComplete, onCancel, onError);

		removeEvents();
		_currentEvent = onSaveComplete;
		_fileRef.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
		_fileRef.save(dataToSave, fileName);
	}

	public function open(?defaultName:String = null, ?title:String = null, ?filter:Array<FileFilter> = null, ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void)
	{
		if(!completed)
		{
			throw new Exception('You must finish previous operation before starting a new one.');
		}

		this._dialogMode = OPEN;
		_startUp(onComplete, onCancel, onError);
		if(filter == null) filter = [new FileFilter('JSON', 'json')];

		removeEvents();
		_currentEvent = onLoadComplete;
		_fileRef.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
		_fileRef.browseEx(OPEN, defaultName, title, filter);
	}

	public function openDirectory(?title:String = null, ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void)
	{
		if(!completed)
		{
			throw new Exception('You must finish previous operation before starting a new one.');
		}

		this._dialogMode = OPEN_DIRECTORY;
		_startUp(onComplete, onCancel, onError);

		removeEvents();
		_currentEvent = onLoadDirectoryComplete;
		_fileRef.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
		_fileRef.browseEx(OPEN_DIRECTORY, null, title);
	}

	public var data:String;
	public var path:String;
	public var completed:Bool = true;
	function onSaveComplete(_)
	{
		this.path = _fileRef._trackSavedPath;
		this.completed = true;
		trace('Saved file to: $path');

		removeEvents();
		this.completed = true;
		if(onComplete != null) onComplete();
	}

	function onLoadComplete(_)
	{
		this.path = _fileRef.__path;
		this.data = File.getContent(this.path);
		this.completed = true;
		trace('Loaded file from: $path');

		removeEvents();
		this.completed = true;
		if(onComplete != null)
			onComplete();
	}

	function onLoadDirectoryComplete(_)
	{
		this.path = _fileRef.__path;
		this.completed = true;
		trace('Loaded directory: $path');

		removeEvents();
		this.completed = true;
		if(onComplete != null)
			onComplete();
	}

	function onCancelFn(_)
	{
		removeEvents();
		this.completed = true;
		if(onCancel != null) onError();
	}

	function onErrorFn(_)
	{
		removeEvents();
		this.completed = true;
		if(onError != null) onError();
	}

	function _startUp(onComplete:Void->Void, onCancel:Void->Void, onError:Void->Void)
	{
		this.onComplete = onComplete;
		this.onCancel = onCancel;
		this.onError = onError;
		this.completed = false;

		this.data = null;
		this.path = null;
	}

	function removeEvents()
	{
		if(_currentEvent == null) return;
		
		_fileRef.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, _currentEvent);
		_currentEvent = null;
	}

	override function destroy()
	{
		removeEvents();
		_fileRef = null;
		_currentEvent = null;
		onComplete = null;
		onCancel = null;
		onError = null;
		data = null;
		path = null;
		completed = true;
		super.destroy();
	}
}