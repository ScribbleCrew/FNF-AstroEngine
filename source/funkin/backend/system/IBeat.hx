package funkin.backend.system;

interface IBeat
{
	public function stepHit():Void;
	public function beatHit():Void;
	public function sectionHit():Void;
}
