package funkin.backend.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class ClassMacro
{
	/**
	* Macro to get all metadata names and return them as strings in an array	
	*
	* @returns Class Metadata
	*/
	public static macro function getMeta():haxe.macro.Expr
	{
		// Access the current local class reference
		final ctRef:Null<Ref<ClassType>> = haxe.macro.Context.getLocalClass();
		if (ctRef == null)
			return macro $v{[]}; // Return an empty array if no class context is returned.

		// Get the actual class type
		final ct:ClassType = ctRef.get();
		final metadata:Array<String> = []; // ik ik, final on an array

		// Loop through all the returning metadata and push them into the array.
		for (m in ct.meta.get())
			metadata.push(m.name); // Add metadata to an array

		// Return the array of metadata names as an Expr
		if (metadata != [])
			return macro $v{metadata}; // Use macro interpolation to wrap it as a valid Haxe expression

		return macro $v{[]};
	}
}
