package rulescript.macro;

import rulescript.Config;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Compiler;
#end

using Lambda;
using haxe.macro.ComplexTypeTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using StringTools;

class RuleScriptedMacro
{
	#if macro
	public static function init():Void
	{
		if (Context.defined("display") || !Context.defined("CUSTOM_CLASSES"))
			return;
		for (v in Config.ALLOWED_CUSTOM_CLASSES)
			if (!v.endsWith(Config.CUSTOM_CLASSES_SHADOW_SUFFIX) || v.contains(Config.CUSTOM_CLASSES_SHADOW_SUFFIX))
				Compiler.addGlobalMetadata(v, '@:build(rulescript.macro.RuleScriptedMacro.build())');
	}

	public static var modifiedClasses:Array<String> = [];
	public static var noMetas:Array<String> = [":bitmap", ":noCustomClass", ":structInit", ":generic", ":nullSafety", ":forceOverride", ":ignoreFields"];

	public static function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		if (fields.length == 0 || fields == null)
			return null;

		final clRef:Null<Ref<ClassType>> = Context.getLocalClass();
		if (clRef == null)
			return null;

		final cl:ClassType = clRef.get();

		if (/*cl.isAbstract || */ cl.isExtern || cl.isInterface || cl.isFinal)
			return null;
		if(cl.name.endsWith(Config.CUSTOM_CLASSES_SHADOW_SUFFIX) || cl.name.contains(Config.CUSTOM_CLASSES_SHADOW_SUFFIX)) return null;
		if (cl.name.endsWith("_Impl_") || modifiedClasses.contains(cl.name))
			return null;
		if (cl.params.length > 0)
			return null;

		if (!cl.module.endsWith(cl.name))
			return null;

		for (m in cl.meta.get())
			if (noMetas.contains(m.name))
				return null;

		// trace(cls.name);

		//	if(curType.constructor == null)

		var key:String = cl.module;
		var fkey:String = cl.module + "." + cl.name;

		for (i in Config.DISALLOW_CUSTOM_CLASSES)
		{
			if (fkey.startsWith(i) || key.startsWith(i))
				return null;
		}
		//trace(cl.name + " isAbstract=" + cl.isAbstract);
		// for(v in Config.disallowedClasses) doesStartWith(v) return null;
		// final interfaceType:Type = Context.getType("rulescript.scriptedClass.RuleScriptedClass");
		// final interfaceRef = null;
		/*:Null<Ref<ClassType>> = switch (interfaceType)
			{
				case TInst(ref, _): ref;
				default: null;
		};*/

		// stolennnnnnnnnnnnnnnnnn
		var _tempCl:ClassType = cl;
		var _isStatic:Bool = (_tempCl.init == null
			&& (fields.filter(f -> return f.access.contains(AStatic) || f.access.contains(AMacro)).length == 0));
		while (_isStatic && _tempCl.superClass != null)
		{
			_tempCl = _tempCl.superClass.t.get();
			_isStatic = (_tempCl.init == null && (_tempCl.fields.get().length == 0));
		}
		if (_isStatic)
			return null;

	//	trace(cl.constructor);

		try
		{
			final shadowClass:TypeDefinition = macro class
				{
				};
			shadowClass.name = cl.name + Config.CUSTOM_CLASSES_SHADOW_SUFFIX; // _RSC
			// shadowClass.pack = shadowInfo.pack;
			shadowClass.kind = TDClass({
				pack: cl.pack.copy(),
				name: cl.name
			},
				[{pack: ["rulescript", "scriptedClass"], name: "RuleScriptedClass", params: []}], false, false, false);
			shadowClass.meta = cl.meta.get().concat([{name: ":ruleScriptedClass", pos: Context.currentPos()}]);
			//	shadowClass.fields = fields;
			// shadowClass.pos = Context.currentPos();

			final imports:Array<ImportExpr> = Context.getLocalImports().copy();
			if (imports == null) return null;

			Context.defineModule(cl.module, [shadowClass], imports);
		}
		catch (e:Dynamic)
			trace('err: ${cl.module}.${cl.name} // $e');

		return fields;
	}
	#end
}
