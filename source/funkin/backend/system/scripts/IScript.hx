package funkin.backend.system.scripts;

interface IScript {
	public function call(functionName:String, ?funcArgs:Array<Dynamic>):Dynamic;
}