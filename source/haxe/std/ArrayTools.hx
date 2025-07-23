package haxe.std;

@:pure
class ArrayTools {
    public static inline function empty<T:Array<Dynamic>>(x:T):T {
		x.splice(0, x.length);
		return x;
	}
}
