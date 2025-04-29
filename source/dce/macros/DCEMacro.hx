package dce.macros;

#if macro
// import haxe.macro.Type;
import Type.ValueType;
import haxe.macro.Expr;
import haxe.macro.*;
import Sys;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;

using StringTools;
using Lambda;
#end

import dce.Config;

class DCEMacro
{
	#if macro
	public static function init():Void
	{
		if (Context.defined("display"))
			return;

		for (apply in Config.ALLOWED_CLASSES)
		{
			Compiler.addGlobalMetadata(apply, "@:keep");
			//Compiler.addGlobalMetadata(apply, "@:build(dce.macros.ClassExtendMacro.build())");
		}

		for (apply in Config.ALLOWED_ABSTRACT_AND_ENUM)
		{
		}
	}
	// TODO make shadow class...
	/*public static function build():Array<Field>
	{
		final fields:Array<Field> = Context.getBuildFields();
		if (fields.length == 0)
			return null;

		final clRef:Null<Ref<ClassType>> = Context.getLocalClass();
		if (clRef == null)
			return null;

		final cl:ClassType = clRef.get();
		final fkey:String = cl.pack.concat([cl.name]).join(".");

		for (i in Config.DISALLOW_CLASSES)
			if (fkey.startsWith(i))
				return null;

		// i'll add more stuff here... -orbl

		return null;
	} */
	#end
}
