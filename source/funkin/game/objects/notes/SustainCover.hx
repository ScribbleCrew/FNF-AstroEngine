package funkin.game.objects.notes;

import haxe.xml.Access;

using funkin.backend.CoolUtil;

typedef SustainCoverXML =
{
	?version:String,
	isPixel:Bool,
	offset:FlxPoint,
}

class SustainCover extends FlxSprite
{
	/**
	 * Start Crochet.    
	 */
	public static var startCrochet:Float;

	/**
	* Frame Rate.	
	*/
	public static var frameRate:Int;

	/**
	* The strum note that this cover is attached to.		
	*/
	public var strumNote:StrumNote;


	var timer:FlxTimer;

	private var _data:SustainCoverXML;

	// todo: make this a proper class
	function parseBool(s:String):Bool
		return s.toLowerCase() == "true";

	public function new():Void
	{
		super();

		x = -50000;

		var correctFPath = '';
		if (ClientPrefs.data.holdSkin != "Normal")
			correctFPath = '-${ClientPrefs.data.holdSkin}';

		trace('holdCovers/holdCover$correctFPath');
		frames = Paths.getSparrowAtlas('holdCovers/holdCover$correctFPath');

		animation.addByPrefix('start', 'holdCoverStart0', 24, false);
		animation.addByPrefix('hold', 'holdCover0', 24, true);
		animation.addByPrefix('end', 'holdCoverEnd0', 24, false);

		_data = {version: "0.0.1", isPixel: false, offset: new FlxPoint(0, 0)};
		try
		{
			final xml:Access = new Access(Xml.parse(Paths.getTextFromFile('data/notes/covers/holdCover$correctFPath.xml')).firstElement());
			if (xml != null)
			{	
				final node:Access = xml.node.pixel;
				if (node!=null && node.name != null)
					_data.isPixel = parseBool(node.has.isPixel ? node.att.isPixel : null).getDefault(false);

				final node:Access = xml.node.offset;
				if (node!=null && node.name != null)
				{
					_data.offset.set(Std.parseFloat(node.has.x ? node.att.x : null).getDefault(0),
						Std.parseFloat(node.has.y ? node.att.y : null).getDefault(0));
				}
				

				// allows me to change the way this works without breaking old xmls.
				_data.version = (xml.has.version ? xml.att.version : null).getDefault("0.0.1");
			}
		}
		catch (error:Dynamic)
			Logs.prefixedTrace(error, 'ERR', RED);

		trace(_data);
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (strumNote != null)
		{
			setPosition(strumNote.x, strumNote.y);
			visible = strumNote.visible;
			alpha = ClientPrefs.data.holdSplashAlpha - (1 - strumNote.alpha);

			if (animation.curAnim.name == "hold" && strumNote.animation.curAnim.name == "static")
			{
				x = -50000;
				kill();
			}
		}
	}

	public function setupSusSplash(strum:StrumNote, daNote:Note, ?playbackRate:Float = 1):Void
	{
		var tailEnd:Note = !daNote.isSustainNote ? daNote.tail[daNote.tail.length - 1] : daNote.parent.tail[daNote.parent.tail.length - 1];

		animation.play('hold', true, false, 0);
		animation.curAnim.frameRate = frameRate;
		animation.curAnim.looped = true;

		clipRect = new flixel.math.FlxRect(0, !PlayState.isPixelStage ? 0 : -210, frameWidth, frameHeight);

		if (daNote.shader != null)
		{
			shader = new NoteSplash.PixelSplashShaderRef().shader;
			shader.data.r.value = daNote.shader.data.r.value;
			shader.data.g.value = daNote.shader.data.g.value;
			shader.data.b.value = daNote.shader.data.b.value;
			shader.data.mult.value = daNote.shader.data.mult.value;
		}

		strumNote = strum;
		alpha = ClientPrefs.data.holdSplashAlpha - (1 - strumNote.alpha);
		offset.set((PlayState.isPixelStage ? 12 : -10 ) + _data.offset.x, _data.offset.y);

		if (timer != null) timer.cancel();

		final lengthToGet:Int = !daNote.isSustainNote ? daNote.tail.length : daNote.parent.tail.length;
		final timeToGet:Float = !daNote.isSustainNote ? daNote.strumTime : daNote.parent.strumTime;

		if (!daNote.hitByOpponent && ClientPrefs.data.holdSplashAlpha != 0)
			timer = new FlxTimer().start((startCrochet * lengthToGet + (timeToGet - Conductor.songPosition + ClientPrefs.data.ratingOffset)) / playbackRate * .001, (_) ->
			{
				if (!(daNote.isSustainNote ? daNote.parent.noteSplashData.disabled : daNote.noteSplashData.disabled) && animation != null)
				{
					alpha = ClientPrefs.data.holdSplashAlpha - (1 - strumNote.alpha);
					animation.play('end', true, false, 0);
					animation.curAnim.looped = false;
					animation.curAnim.frameRate = 24;
					clipRect = null;
					animation.finishCallback = (idkEither:Dynamic) -> kill();
					return;
				}
				kill();
			});
	}
}
