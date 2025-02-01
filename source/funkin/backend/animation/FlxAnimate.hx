package funkin.backend.animation;

import flxanimate.frames.FlxAnimateFrames;
import flixel.util.FlxDestroyUtil;
#if sys
import sys.io.File;
#else
import openfl.utils.Assets;
#end

using StringTools;

class FlxAnimate extends flxanimate.FlxAnimate
{
	public function loadAtlasEx(img:flixel.system.FlxAssets.FlxGraphicAsset, pathOrStr:String = null, myJson:Dynamic = null):Void
	{
		var animJson:flxanimate.data.AnimationData.AnimAtlas = null;
		if (myJson is String)
		{
			var trimmed:String = pathOrStr.trim();
			trimmed = trimmed.substr(trimmed.length - 5).toLowerCase();

			if (trimmed == '.json')
				myJson = #if sys File.getContent(myJson) #else daList = Assets.getText(myJson) #end;

			animJson = cast tjson.TJSON.parse(_removeBOM(myJson));
		}
		else
			animJson = cast myJson;

		var isXml:Null<Bool> = null;
		var myData:Dynamic = pathOrStr;

		var trimmed:String = pathOrStr.trim();
		trimmed = trimmed.substr(trimmed.length - 5).toLowerCase();

		if (trimmed == '.json') // Path is json
		{
			myData = #if sys File.getContent(pathOrStr) #else Assets.getText(pathOrStr) #end;
			isXml = false;
		}
		else if (trimmed.substr(1) == '.xml') // Path is xml
		{
			myData = #if sys File.getContent(pathOrStr) #else Assets.getText(pathOrStr) #end;
			isXml = true;
		}
		myData = _removeBOM(myData);

		// Automatic if everything else fails
		switch (isXml)
		{
			case true:
				myData = Xml.parse(myData);
			case false:
				myData = tjson.TJSON.parse(myData);
			case null:
				try
				{
					myData = tjson.TJSON.parse(myData);
					isXml = false;
				}
				catch (e)
				{
					myData = Xml.parse(myData);
					isXml = true;
				}
		}

		anim._loadAtlas(animJson);
		frames = !isXml ? FlxAnimateFrames.fromSpriteMap(cast myData, img) : FlxAnimateFrames.fromSparrow(cast myData, img);
		origin = anim.curInstance.symbol.transformationPoint;
	}

	/**
	 *	draw.
	 */
	override function draw():Void
	{
		if (anim.curInstance == null || anim.curSymbol == null) return;
		super.draw();
	}

	/**
	 *	destroy.
	 */
	override function destroy():Void
	{
		try
			super.destroy()
		catch (e:Dynamic)
		{
			anim.curInstance = FlxDestroyUtil.destroy(anim.curInstance);
			anim.stageInstance = FlxDestroyUtil.destroy(anim.stageInstance);
			anim.metadata.destroy();
			anim.symbolDictionary = null;
		}
	}

	/**
	 *	Removes BOM byte order indicator
	 */
	private function _removeBOM(str:String)
		return str.charCodeAt(0) == 0xFEFF ? str.substr(1) : str;

	/**
	 *	Resume the animation.
	 */
	public function resumeAnimation():Void
	{
		if (anim.curInstance == null || anim.curSymbol == null) return;
		anim.play();
	}

	/**
	 *	Pause the animation.
	 */
	public function pauseAnimation():Void
	{
		if (anim.curInstance == null || anim.curSymbol == null) return;
		anim.pause();
	}
}
