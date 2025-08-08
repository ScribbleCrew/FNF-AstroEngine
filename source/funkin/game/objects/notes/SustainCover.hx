package funkin.game.objects.notes;

import haxe.ds.StringMap;

using funkin.backend.CoolUtil;

typedef TwoDimensionalPoint =
{
	var x:Float;
	var y:Float;
}

typedef PrefixedType =
{
	var fps:Int;
	var prefix:String;
	var indices:Array<Int>;
	var offset:TwoDimensionalPoint;
	var loop:Bool;
	var antialiasing:Bool;
}

typedef SustainCoverAnim =
{
	var anim_prefixes:Map<String, PrefixedType>;
	var noteData:Array<Int>;
}

typedef SustainCoverData =
{
	@:optional var version:String;

	var scale:Float;
	var allowRGB:Bool;
	var allowPixel:Bool;

	var animations:Map<String, SustainCoverAnim>;
}

typedef PixelShaderRef = NoteSplash.PixelSplashShaderRef;

// TODO: make an editor + more options??? + optim ?????

class SustainCover extends FlxSprite
{
	@:noCompletion static var __stepCrochet:Float;
	@:noCompletion static var __rate:Int;

	/**
	 * Default Sustain Splash Asset.	
	 */
	public static var defaultSustainSplash:String = 'holdCovers/holdCover';

	/**
	 * Strum note.	
	 */
	public var strumNote:StrumNote;

	@:noCompletion var __tmr:FlxTimer;
	@:noCompletion var __data:SustainCoverData;
	@:noCompletion var __offsetmap:Map<String, Map<String, TwoDimensionalPoint>>;

	/**
	 * Formatted sustain cover prefix
	 * e.g -normal, -cosmo
	 */
	@:noCompletion var dataPrefix(get, never):String;

	@:dox(hide) @:noCompletion function get_dataPrefix():String
		return ClientPrefs.data.holdSplashesSkin != "Normal" ? '-${ClientPrefs.data.holdSplashesSkin}' : "";

	// constructor
	public function new():Void
	{
		super();

		__offsetmap = new StringMap();

		// setup shitz
		animation = new AnimationController(this);
		frames = Paths.getSparrowAtlas('${Constants.DEFAULT_SUSTAIN_COVER}$dataPrefix');
		kill();
		x = -50000;
	}

	/**
	 * Custom play animation function
	 * @param noteID The noteID.
	 * @param animName The Animation Name.	
	 * @param force Force The Animation.
	 * @param reversed If the animation should be reversed.
	 * @param frame The animation frame.	
	 */
	public function playAnim(noteID:Int, animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		final prefixOffsets:Null<Map<String, Dynamic>> = __offsetmap.get(Note.noteIDToName(noteID));
		final prefixOffset:TwoDimensionalPoint = prefixOffsets.exists(animName) ? prefixOffsets.get(animName) : {x: 0, y: 0};
		offset.set((PlayState.isPixelStage ? 12 : -10) + prefixOffset.x ?? 0, prefixOffset.y ?? 0);
		animation.play(animName, force, reversed, frame);
	}

	/**
	 * Load the json config for the sustain splashes.
	 * @param custom (Optional) Load a custom .json file.	
	 */
	public function load(?custom:String):Void
	{
		final raw:Dynamic = tjson.TJSON.parse(Paths.getTextFromFile(custom != null ? custom : 'data/notes/covers/holdCover$dataPrefix.json'));
		if (raw != null)
		{
			// temp data for reformatting
			final ___data:SustainCoverData = {
				version: raw.version ?? "0.0.1",
				animations: new Map<String, SustainCoverAnim>(),
				scale: raw.scale ?? 1,
				allowRGB: raw.allowRGB ?? true,
				allowPixel: raw.allowPixel ?? true
			};

			final rawAnims:Map<String, Dynamic> = CoolUtil.objectToMap(raw.animations);
			for (key in rawAnims.keys())
			{
				final anim:Dynamic = rawAnims.get(key);
				if (anim != null)
				{
					if (!Reflect.hasField(anim, "anim_prefixes") || anim.anim_prefixes == null)
						anim.anim_prefixes = new Map<String, Dynamic>();
					___data.animations.set(key, cast anim);
				}
			}

			// update the normal data
			__data = ___data;
		}
	}

	@:noCompletion var __pixelShaderRef:PixelShaderRef;

	/**
	 * Setup the sustain splash
	 * @param strum The strum note in question.
	 * @param daNote The note in question.
	 * @param playbackRate (Optional) the playback rate.	
	 */
	public function setupSustainSplash(strum:StrumNote, daNote:Note, ?playbackRate:Float = 1):Void
	{
		// load da config
		this.load();

		for (key in __data.animations.keys())
		{
			var anim = __data.animations.get(key);
			if (anim == null || anim.noteData.indexOf(daNote.noteData) == -1)
				continue;

			var prefixOffsets:StringMap<TwoDimensionalPoint> = new StringMap<TwoDimensionalPoint>();

			var prefixes:Map<String, Dynamic> = CoolUtil.objectToMap(anim.anim_prefixes);

			for (part in prefixes.keys())
			{
				final prefixEntry = prefixes.get(part);
				if (Std.is(prefixEntry, String))
					prefixOffsets.set(part, {x: 0, y: 0}); // i hate gravel
				else
				{
					final offsetObj = Reflect.hasField(prefixEntry, "offset") ? Reflect.field(prefixEntry, "offset") : null;
					if (offsetObj != null && Reflect.hasField(offsetObj, "x") && Reflect.hasField(offsetObj, "y"))
						prefixOffsets.set(part, {x: offsetObj.x, y: offsetObj.y});
					else
						prefixOffsets.set(part, {x: 0, y: 0});
				}
			}

			__offsetmap.set(key, prefixOffsets);

			for (part in prefixes.keys())
			{
				var prefix = prefixes.get(part);
				if (prefix != null && (Std.is(prefix, String) ? prefix.length > 0 : true))
				{
					final prefixStr:String = Std.is(prefix, String) ? prefix : prefix.prefix;
					if (prefix.indices != null && prefix.indices.length > 0)
						animation.addByIndices(part, prefixStr, prefix.indices, "", prefix.fps, prefix.loop);
					else
						animation.addByPrefix(part, prefixStr, prefix.fps, prefix.loop);

					antialiasing = (prefix.antialiasing ?? true);
				}
			}
		}

		// set the data scale
		scale.set(__data.scale, __data.scale);

		// play hold anim
		playAnim(daNote.noteData, 'hold', true, false, 0);
		if (animation.curAnim != null)
		{
			animation.curAnim.frameRate = __rate ?? 24;
			animation.curAnim.looped = true;
		}

		clipRect = new flixel.math.FlxRect(0, PlayState.isPixelStage ? -210 : 0, frameWidth, frameHeight);

		if (daNote.shader != null && __data.allowRGB)
		{
			__pixelShaderRef = new PixelShaderRef();
			shader = __pixelShaderRef.shader;
			shader.data.r.value = daNote.shader.data.r.value;
			shader.data.g.value = daNote.shader.data.g.value;
			shader.data.b.value = daNote.shader.data.b.value;
			shader.data.mult.value = daNote.shader.data.mult.value;

			__pixelShaderRef.pixelAmount = !__data.allowPixel ? 1 : PlayState.isPixelStage ? 6 : __pixelShaderRef.pixelAmount;
		}

		strumNote = strum;
		alpha = ClientPrefs.data.holdSplashesAlpha - (1 - strumNote.alpha);

		// cancel the timer
		if (__tmr != null)
			__tmr.cancel();

		if (!daNote.hitByOpponent && ClientPrefs.data.holdSplashesAlpha != 0)
		{
			__tmr = new FlxTimer().start((__stepCrochet * (!daNote.isSustainNote ? daNote.tail.length : daNote.parent.tail.length)
				+ ((!daNote.isSustainNote ? daNote.strumTime : daNote.parent.strumTime)
					- Conductor.songPosition
					+ ClientPrefs.data.ratingOffset)) / playbackRate * 0.001,
				(_) ->
				{
					if (!(daNote.isSustainNote ? daNote.parent.noteSplashData.disabled : daNote.noteSplashData.disabled)
						&& animation != null)
					{
						alpha = ClientPrefs.data.holdSplashesAlpha - (1 - strumNote.alpha);
						playAnim(daNote.noteData, "end", true, false, 0);
						if (animation.curAnim != null)
						{
							animation.curAnim.looped = false;
							animation.curAnim.frameRate = 24;
							animation.finishCallback = (_) -> kill();
						}
						clipRect = null;
						return;
					}
					kill();
				});
		}
	}

	@:dox(hide) override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (strumNote != null)
		{
			setPosition(strumNote.x, strumNote.y); // track the strumNote
			visible = strumNote.visible;
			alpha = ClientPrefs.data.holdSplashesAlpha - (1 - strumNote.alpha);

			if (animation.curAnim != null
				&& animation.curAnim.name == "hold"
				&& strumNote.animation.curAnim != null
				&& strumNote.animation.curAnim.name == "static")
			{
				visible = false;
				kill();
			}
		}
	}

	@:dox(hide) override function destroy():Void
	{
		if (__tmr != null)
		{
			__tmr.cancel();
			__tmr = FlxDestroyUtil.destroy(__tmr);
		}

		if (__offsetmap != null)
			__offsetmap.clear();
	}
}
