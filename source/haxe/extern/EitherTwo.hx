package haxe.extern;

/**
 * Very useful, not all of these are currently being used. :3
 * Also! (the type is technically typeless (dynamic) so the use of `Std.isOfType()` and `cast(obj, TYPE)` // `cast obj` 
 * is absolutely necessary).
 */
@:transitive
abstract EitherTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2{}