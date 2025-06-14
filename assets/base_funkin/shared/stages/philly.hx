package stages;

// TODO: optim
import objects.PhillyGlow.GlowGradient as GlowGradient;
import objects.PhillyGlow.GlowParticle as GlowParticle;
import objects.PhillyTrain as Train;

var curLight:Int = -1;
final phillyLightsColors:Array<FlxColor> = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
var phillyWindow:BGSprite;
var phillyStreet:BGSprite;
var _train:Train;

// For Philly Glow events
var blammedLightsBlack:FlxSprite;
var GlowGradient:GlowGradient;
var GlowParticles:FlxGroup;
var phillyWindowEvent:BGSprite;
var curLightEvent:Int = -1;

function onCreate():Void
{
	if (!ClientPrefs.data.lowQuality) // bg
		addHxObject(new BGSprite('philly/sky', -100, 0, 0.1, 0.1));

	var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
	city.setGraphicSize(Std.int(city.width * 0.85));
	city.updateHitbox();
	addHxObject(city);

	phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
	phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
	phillyWindow.updateHitbox();
	addHxObject(phillyWindow);
	phillyWindow.alpha = 0;

	if (!ClientPrefs.data.lowQuality)
		addHxObject(new BGSprite('philly/behindTrain', -40, 50)); // streetBehind
	addHxObject(_train = new Train(2000, 360));
	addHxObject(phillyStreet = new BGSprite('philly/street', -40, 50));
}

function onEventPushed(event:EventNote):Void
{
	switch (event.event)
	{
		case "Philly Glow":
			blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			blammedLightsBlack.visible = false;
			insert(members.indexOf(phillyStreet), blammedLightsBlack);

			phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
			phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
			phillyWindowEvent.updateHitbox();
			phillyWindowEvent.visible = false;
			insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);

			GlowGradient = new GlowGradient(-400, 225); // This shit was refusing to properly load FlxGradient so fuck it
			GlowGradient.visible = false;
			insert(members.indexOf(blammedLightsBlack) + 1, GlowGradient);
			if (!ClientPrefs.data.flashing)
				GlowGradient.intendedAlpha = 0.7;

			Paths.image('philly/particle'); // precache philly glow particle image
			GlowParticles = new FlxGroup();
			GlowParticles.visible = false;
			insert(members.indexOf(GlowGradient) + 1, GlowParticles);
	}
}

function onUpdate(elapsed:Float)
{
	phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
	if (GlowParticles != null)
	{
		var i:Int = GlowParticles.members.length - 1;
		while (i > 0)
		{
			var particle = GlowParticles.members[i];
			if (particle.alpha <= 0)
			{
				particle.kill();
				GlowParticles.remove(particle, true);
				particle.destroy();
			}
			--i;
		}
	}
}

function onBeatHit()
{
	_train.beatHit(curBeat);
	if (curBeat % 4 == 0)
	{
		curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
		phillyWindow.color = phillyLightsColors[curLight];
		phillyWindow.alpha = 1;
	}
}

function onEventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
{
	switch (eventName)
	{
		case "Philly Glow":
			if (flValue1 == null || flValue1 <= 0)
				flValue1 = 0;
			var lightId:Int = Math.round(flValue1);

			var chars:Array<Character> = [boyfriend, gf, dad];
			switch (lightId)
			{
				case 0:
					if (GlowGradient.visible)
					{
						flashCamera();
						if (ClientPrefs.data.camZooms)
						{
							FlxG.camera.zoom += 0.5;
							camHUD.zoom += 0.1;
						}

						blammedLightsBlack.visible = false;
						phillyWindowEvent.visible = false;
						GlowGradient.visible = false;
						GlowParticles.visible = false;
						curLightEvent = -1;

						for (who in chars)
							who.color = FlxColor.WHITE;
						phillyStreet.color = FlxColor.WHITE;
					}

				case 1: // turn on
					curLightEvent = FlxG.random.int(0, phillyLightsColors.length - 1, [curLightEvent]);
					var color:FlxColor = phillyLightsColors[curLightEvent];

					if (!GlowGradient.visible)
					{
						flashCamera();
						if (ClientPrefs.data.camZooms)
						{
							FlxG.camera.zoom += 0.5;
							camHUD.zoom += 0.1;
						}

						blammedLightsBlack.visible = true;
						blammedLightsBlack.alpha = 1;
						phillyWindowEvent.visible = true;
						GlowGradient.visible = true;
						GlowParticles.visible = true;
					}
					else if (ClientPrefs.data.flashing)
					{
						var colorButLower:FlxColor = color;
						colorButLower.alphaFloat = 0.25;
						FlxG.camera.flash(colorButLower, 0.5, null, true);
					}

					var charColor:FlxColor = color;
					if (!ClientPrefs.data.flashing)
						charColor.saturation *= 0.5;
					else
						charColor.saturation *= 0.75;

					for (who in chars)
					{
						who.color = charColor;
					}
					GlowParticles.forEachAlive(function(particle:GlowParticle)
					{
						particle.color = color;
					});
					GlowGradient.color = color;
					phillyWindowEvent.color = color;

					color.brightness *= 0.5;
					phillyStreet.color = color;

				case 2: // spawn particles
					if (!ClientPrefs.data.lowQuality)
					{
						var particlesNum:Int = FlxG.random.int(8, 12);
						var width:Float = (2000 / particlesNum);
						var color:FlxColor = phillyLightsColors[curLightEvent];
						for (j in 0...3)
						{
							for (i in 0...particlesNum)
							{
								var particle:GlowParticle = new GlowParticle(-400
									+ width * i
									+ FlxG.random.float(-width / 5, width / 5),
									GlowGradient.originalY
									+ 200
									+ (FlxG.random.float(0, 125) + j * 40), color);
								GlowParticles.add(particle);
							}
						}
					}
					GlowGradient.bop();
			}
	}
}

function flashCamera():Void
{
	final color:FlxColor = FlxColor.WHITE;
	if (!ClientPrefs.data.flashing)
		color.alphaFloat = 0.5;
	FlxG.camera.flash(color, 0.15, null, true);
}
