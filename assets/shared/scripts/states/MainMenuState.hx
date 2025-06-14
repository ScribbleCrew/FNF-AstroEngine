package states;

function create():Void
{
	this.menuButtons = [
		{
			name: 'story mode',
			state: new funkin.game.states.StoryMenuState()
		},
		{
			name: 'freeplay',
			state: new funkin.game.states.FreeplayState()
		},
		#if ACHIEVEMENTS_ALLOWED
		{
			name: 'awards',
			state: new funkin.game.states.AchievementsMenuState()
		},
		#end
		#if !switch
		{ //// idon'trllywantdisherelol i'm not even trying to being selfish
			name: 'donate',
			link: 'https://ninja-muffin24.itch.io/funkin'
		},
		#end
		{
			preloaded: true,
			name: 'options',
			state: new funkin.game.states.OptionsState(),
			onChange: () ->
			{
				if (PlayState.SONG != null)
				{
					PlayState.SONG.arrowSkin = null;
					PlayState.SONG.splashSkin = null;
					PlayState.stageUI = 'normal';
				}
			}
		},
		{
			name: 'credits',
			state: new funkin.game.states.CreditsState()
		}
	];
}
