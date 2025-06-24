package funkin.modding.interfaces;

interface IScript {
	public function call(functionName:String, ?funcArgs:Array<Dynamic>):Dynamic;
}