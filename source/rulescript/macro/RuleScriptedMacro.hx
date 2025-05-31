package rulescript.macro;

import rulescript.Config;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Compiler;
#end

using StringTools;

class RuleScriptedMacro
{
	#if macro
	public static function init():Void
	{
		if (Context.defined("display") || !Context.defined("CUSTOM_CLASSES"))
			return;
		for (apply in Config.ALLOWED_CUSTOM_CLASSES)
			if (!apply.endsWith(Config.CUSTOM_CLASSES_SHADOW_PREFIX))
				Compiler.addGlobalMetadata(apply, '@:build(rulescript.macro.RuleScriptedMacro.build())');
	}

	public static var modifiedClasses:Array<String> = [];
	public static var unallowedMetas:Array<String> = [":structInit", ":bitmap", ":noCustomClass", ":generic", ":nullSafety"];

	static function getShadowPackAndName(cl:ClassType, suffix:String):{pack:Array<String>, name:String}
	{
		var moduleParts = cl.module.split(".");
		var className = cl.name;
		if (moduleParts[moduleParts.length - 1] != className)
		{
			return {
				pack: moduleParts,
				name: className + suffix
			};
		}
		else
		{
			// Normal case
			return {
				pack: cl.pack.copy(),
				name: className + suffix
			};
		}
	}

	public static function build():Array<Field>
	{
		final fields:Array<Field> = Context.getBuildFields();
		if (fields.length == 0 || fields == null)
			return null;

		final clRef:Null<Ref<ClassType>> = Context.getLocalClass();
		if (clRef == null)
			return null;

		final cl:ClassType = clRef.get();

		if (cl.name.endsWith(Config.CUSTOM_CLASSES_SHADOW_PREFIX))
			return null;
		if (cl.module.endsWith(Config.CUSTOM_CLASSES_SHADOW_PREFIX))
			return null;

		if (cl.isAbstract
			|| cl.isExtern
			|| cl.isFinal
			|| cl.isInterface
			|| cl.params.length > 0 // generic classes
			|| cl.name.endsWith("_Impl_")
			|| cl.name.endsWith(Config.CUSTOM_CLASSES_SHADOW_PREFIX)
			|| modifiedClasses.contains(cl.name)
			|| !cl.module.endsWith(cl.name) // only deepest class
		)
			return null;

		if (cl.params.length > 0)
			return null;
		if (!cl.module.endsWith(cl.name))
			return null;
		trace(cl.name);

		for (m in cl.meta.get())
			if (unallowedMetas.contains(m.name))
				return null;

		final key:String = cl.module;
		for (v in Config.DISALLOW_CUSTOM_CLASSES)
			if (('$key.${cl.name}').startsWith(v) || key.startsWith(v))
				return null;
		// for(v in Config.disallowedClasses) doesStartWith(v) return null;
		final interfaceType:Type = Context.getType("rulescript.scriptedClass.RuleScriptedClass");
		final interfaceRef:Null<Ref<ClassType>> = switch (interfaceType)
		{
			case TInst(ref, _): ref;
			default: null;
		};

		var _tempCl:ClassType = cl;

		var isStaticModule:Bool = _tempCl.init == null
			&& fields.filter(i -> return i.access.contains(AStatic) || i.access.contains(AMacro)).length == 0;
		while (isStaticModule && _tempCl.superClass != null)
		{
			_tempCl = _tempCl.superClass.t.get();
			isStaticModule = _tempCl.init == null && _tempCl.fields.get().length == 0;
		}
		if (isStaticModule)
			return null;

		var shadowInfo = getShadowPackAndName(cl, Config.CUSTOM_CLASSES_SHADOW_PREFIX);

		final shadowClass:TypeDefinition = macro class
			{
			};
		//shadowClass.pack = cl.pack.copy();
		shadowClass.name = cl.name + Config.CUSTOM_CLASSES_SHADOW_PREFIX;
		shadowClass.kind = TDClass({
			pack: cl.pack.copy(),
			name: cl.name
		},
			(interfaceRef != null) ? [{pack: ["rulescript", "scriptedClass"], name: "RuleScriptedClass", params: []}] : [], false, true, false);
		// shadowClass.meta = [];
		shadowClass.meta = cl.meta.get();
		shadowClass.fields = [];
		shadowClass.pos = Context.currentPos();

		var moduleName = cl.module; // Use the original class's module
		var imports = Context.getLocalImports().copy();
		trace(moduleName);
		Context.defineModule(moduleName, [shadowClass], imports);
		Utils.setupMetas(shadowClass, imports);

		return fields;
	}
	#end
}
