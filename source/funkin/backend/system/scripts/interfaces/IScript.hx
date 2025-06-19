package funkin.backend.system.scripts.interfaces;

interface IScript {
	public function call(functionName:String, ?funcArgs:Array<Dynamic>):Dynamic;
}