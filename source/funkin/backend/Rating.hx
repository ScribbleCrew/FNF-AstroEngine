package funkin.backend;

import funkin.game.states.PlayState;

class Rating
{
	public var name:String = '';
	public var image:String = '';
	public var counter:String = '';
	public var hitWindow:Null<Int> = 0; // ms
	public var ratingMod:Float = 1;
	public var score:Int = 350;
	public var noteSplash:Bool = true;
	public var hits:Int = 0;

	public function new(name:String)
	{
		this.name = name;
		this.image = name;
		this.counter = name + 's';
		this.hitWindow = Reflect.field(funkin.backend.utils.ClientPrefs.data, name + 'Window');
		if (hitWindow == null)
			hitWindow = 0;
	}

	public static function loadDefault():Array<Rating>
	{
		final ratingsData:Array<Rating> = [new Rating('sick')]; // highest rating goes first

		final rating:Rating = new Rating('good');
		rating.ratingMod = 0.67;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		final rating:Rating = new Rating('bad');
		rating.ratingMod = 0.34;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		final rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);
		return ratingsData;
	}
}
