package rulescript.macro;

#if macro
import haxe.macro.Type.ClassType;
import Type.ValueType;
import haxe.macro.Expr.Function;
import haxe.macro.Expr;
import haxe.macro.Type.MetaAccess;
import haxe.macro.Type.FieldKind;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.VarAccess;
import haxe.macro.*;

using StringTools;
#end

class Utils
{// stolen from redar13's hscript improved fork
	#if macro
	public static function setupMetas(shadowClass:TypeDefinition, imports)
	{
		if (shadowClass.meta == null)
			shadowClass.meta = [];
		shadowClass.meta = shadowClass.meta.concat([
			{name: ":dox", params: [macro hide], pos: Context.currentPos()},
			{name: ":noCompletion", params: [], pos: Context.currentPos()}
		]);
		var module = Context.getModule(Context.getLocalModule());
		for (t in module)
		{
			switch (t)
			{
				case TInst(t, params):
					if (t != null)
					{
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TEnum(t, params):
					if (t != null)
					{
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TType(t, params):
					if (t != null)
					{
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TAbstract(t, params):
					if (t != null)
					{
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				default:
					// not needed?
			}
		}
	}

	public static function processModule(shadowClass:TypeDefinition, module:String, n:String)
	{
		n = removeImpl(n);
		module = removeImpl(module);

		shadowClass.meta.push({
			name: ':access',
			params: [
				Context.parse(fixModuleName(module.endsWith('.$n') ? module : '${module}.${n}'), Context.currentPos())
			],
			pos: Context.currentPos()
		});
	}

	/*public static function getModuleName(path:Type) {
		switch(path) {
			case TPath(name, pack):// | TDClass(name, pack):
				var str = "";
				for(p in pack) {
					str += p + ".";
				}
				str += name;
				return str;

			default:
		}
		return "INVALID";
	}*/
	public static function fixModuleName(name:String)
	{
		return name;
		// var split = name.split(".");
		// if (split.length > 1 && split[split.length - 2].charAt(0) == "_")
		// 	split[split.length - 2] = split[split.length - 2].substr(1);
		// return split.join(".");
	}

	public static function removeImpl(name:String)
	{
		if (name.endsWith("_Impl_"))
			name = name.substr(0, name.length - 6);
		return name;
	}

	public static function processImport(imports:Array<ImportExpr>, module:String, n:String)
	{
		n = removeImpl(n);
		module = fixModuleName(module);
		module = removeImpl(module);

		imports.push({
			path: [
				for (m in module.split("."))
					{
						name: m,
						pos: Context.currentPos()
					}
			],
			mode: INormal
		});
	}
	#end
}
