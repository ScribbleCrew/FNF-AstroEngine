package funkin.backend.system.scripts;

import rulescript.scriptedClass.RuleScriptedClass.ScriptedClass;
import hscript.Printer;
import hscript.Expr.ClassDecl;
import hscript.Expr.ModuleDecl;

class HScriptUtils
{
	@:noUsing public static function onError(error:haxe.Exception):Dynamic
	{
		final details:String = error.details();
		Logs.prefixedTrace(details, 'ERROR', RED);
		return details;
	}

	/**
	 * Gets a scripted macro class created by rulescript.
	 */
	@:noUsing public static inline function getScriptedClass(className:String)
		return Type.resolveClass('${className}${Config.CUSTOM_CLASSES_SHADOW_PREFIX}');
	
	public static function tryParseModule(code : String) : Array<ModuleDecl>
	{
		try
		{
			final parser:HxParser = new HxParser();
			parser.allowAll();
			parser.mode = MODULE;
			return parser.parseModule(code);
		}
		catch (error)
			onError(error);
		return null;
	}

	public static function resolveModule(name:String):Array<ModuleDecl>
	{
		var path:Array<String> = name.split('.');

		var pack:Array<String> = [];

		while (path[0].charAt(0) == path[0].charAt(0).toLowerCase())
			pack.push(path.shift());

		var moduleName:String = null;

		if (path.length > 1)
			moduleName = path.shift();

		// Replace type path dots to slash.
		final packName = '${(pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]).replace('.', '/')}.hx';
		final filePath = 'source/$packName';

		#if MODS_ALLOWED
		for (mod in (Mods.parseList().enabled).concat(['']))
		{
			final modPath:String = Paths.mods(mod + '/$filePath');
			if (FileSystem.exists(modPath))
			{
				return tryParseModule(File.getContent(modPath));
			}
		}
		#end

		// Check file.
		var full = 'assets/' + filePath;
		if (!FileSystem.exists(full))
			return null;
		return tryParseModule(File.getContent(full));
	}
}
