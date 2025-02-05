package haxe.extern;

/**
 * Very useful, not all of these are currently being used.
 * Also! (the type is technically typeless (dynamic) so the use of `Std.isOfType()` and `cast(obj, TYPE)` // `cast obj` 
 * is absolutely necessary).
 */
@:transitive
abstract EitherFour<T1, T2, T3, T4>(Dynamic) from T1 from T2 from T3 from T4 to T1 to T2 to T3 to T4{}