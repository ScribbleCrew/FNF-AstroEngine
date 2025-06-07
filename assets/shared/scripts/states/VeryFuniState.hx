package states;

/**                                     
 *      :                             :     
 *     t#,                           t#,    
 *    ;##W.                         ;##W.   
 *   :#L:WE             ;          :#L:WE   
 *  .KG  ,#D          .DL         .KG  ,#D  
 *  EE    ;#f f.     :K#L     LWL EE    ;#f 
 * f#.     t#iEW:   ;W##L   .E#f f#.     t#i
 * :#G     GK E#t  t#KE#L  ,W#;  :#G     GK 
 *  ;#L   LW. E#t f#D.L#L t#K:    ;#L   LW. 
 *   t#f f#:  E#jG#f  L#LL#G       t#f f#:  
 *    f#D#;   E###;   L###j         f#D#;   
 *     G#t    E#K:    L#W;           G#t    
 *      t     EG      LE.             t     
 *            ;       ;@                    
 *                           
 * CUSTOM STATE EXAMPLE!!!!1111
 * Use this state as an example and use `Template.hx` as an base. 
 * (NOTICE: ENUMS/TYPEDEF/CLASSES NOT CURRENTLY SUPPORTED BY HSCRIPT-IRIS, PLEASE TRY FIND ANOTHER WAY, MAKE A PR IF YOU HAVE A RELIABLE METHOD).	
 */

// idk but softmoddin' weird!!!
import funkin.game.states.MainMenuState;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxAxes;
import flixel.util.FlxDestroyUtil;

using funkin.backend.utils.ObjectUtils;

// Shouldn't be static as this is a returning state (going to be used more than once).
var leaving:Bool = false;

// sprites
var background:FlxSprite;
var title:FlxText;
var daKisser:FlxSprite;

// window timer
var titleTimer:FlxTimer;

// title options
final titles:Array<String> = [':3', '>:3c', '>;3c', '=3', ';3c', ';3', ':3c'];

// the returning state.
var returningState:FlxState = null;

// really cool new function (took me forever to implement this).
function new(returnState:FlxState):Void
	returningState = returnState;

function create():Void
{
	// lightmode stuff
	savedDarkmodeSetting = WindowUtil.darkmode;
	WindowUtil.darkmode = false;

	// ugh... flixel being weird
	// FlxG.sound.music.stop();

	titleTween();
	makeSprites();

	FlxTween.tween(daKisser, {x: daKisser.x}, 0.3, {ease: FlxEase.expoOut, type: FlxTween.PINGPONG, onComplete: (twn) -> daKisser.flipX = !daKisser.flipX});
	FlxTween.num(Main.framerateCounter.alpha, 0, .6, {ease: FlxEase.expoOut, startDelay: .2}, Main.framerateCounter.set_alpha);
}

// setup the window title changer
function titleTween():Void
{
	titleTimer = new FlxTimer().start(2.5, (timer) -> WindowUtil.title = titles[FlxG.random.int(0, titles.length - 1)], 0);
	titleTimer.onComplete(titleTimer);
}

// make the sprites for this cool state.
function makeSprites():Void
{
	// wahahah
	background = new FlxSprite().makeSolid(1, 1, FlxColor.WHITE);
	background.scale.set(FlxG.width, FlxG.height);
	background.screenCenter();
	add(background);

	// title, lol :3
	title = new FlxText().setFormat(Paths.font("Futura-CondensedExtraBold.otf"), 70, FlxColor.BLACK, FlxTextAlign.CENTER);
	title.text = "Oooooo you like boys\nur a boykisser".toLowerCase();
	title.screenCenter(FlxAxes.X);
	title.y += 25;
	title.updateHitbox();
	add(title);

	// da main cutie.
	daKisser = new FlxSprite().loadGraphic(Paths.image('extra/kisser'));
	daKisser.screenCenter();
	daKisser.updateHitbox();
	daKisser.y += 25;
	add(daKisser);
}

function destroy():Void
	titleTimer = FlxDestroyUtil.destroy(titleTimer);

var savedDarkmodeSetting:Bool = false;

function update(elapsed:Float):Void
{
	// if(FlxG.state?.subState != null) return;

	if (FlxG.keys.justPressed.SIX)
	{
		// persistentUpdate = false;
		// persistentDraw = true;
		openSubState(new MusicBeatSubstate("ExampleSubstate", []));
		return;
	}

	if (!leaving && FlxG.keys.justPressed.ANY)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		leaving = true;
		titleTimer.cancel();
		WindowUtil.title = "wawawawawawawawawawawa";
		WindowUtil.darkmode = true;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxTween.cancelTweensOf(daKisser);
		FlxG.camera.flash(0xFFFFC0CB);
		FlxTween.tween(FlxG.camera, {zoom: 1.8}, 6, {ease: FlxEase.expoOut});

		new FlxTimer().start(5.55, _ -> FlxG.camera.fade(FlxColor.BLACK, .1, false, () ->
		{
			WindowUtil.darkmode = savedDarkmodeSetting;
			MusicBeatState.switchState(returningState ?? new MainMenuState());
		}));

		FlxTween.tween(title, {alpha: 0}, .5, {ease: FlxEase.expoOut});
		FlxTween.tween(background, {alpha: 0}, .75, {
			ease: FlxEase.expoOut,
			onComplete: _ -> FlxTween.tween(daKisser, {alpha: 0}, 3.5, {
				ease: FlxEase.expoOut,
				onComplete: _ ->
				{
					FlxTween.num(Main.framerateCounter.alpha, ClientPrefs.data.fpsCounterAlpha, .5, {ease: FlxEase.expoOut}, Main.framerateCounter.set_alpha);
					WindowUtil.title = '%{GAME_TITLE}'; // YEAH!
				}
			})
		});
	}
}
