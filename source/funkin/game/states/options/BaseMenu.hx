package funkin.game.states.options;

class BaseMenu extends MusicBeatSubstate
{
	private var bg:FlxSprite;
	private var grid:FlxSprite;

	public function new()
	{
		super();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = funkin.backend.utils.ClientPrefs.data.antialiasing;
		bg.color = EngineData.MENU_COLOR;
		bg.screenCenter();
		add(bg);

		grid = new FlxBackdrop(Paths.image('ui/grids/grid', 'embed'), XY);
		grid.screenCenter();
		grid.velocity.x = -30;
		grid.velocity.y = -30;
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: .2}, .5, {ease: FlxEase.cubeOut});
		//FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);
	}
}
