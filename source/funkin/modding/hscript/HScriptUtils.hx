package funkin.modding.hscript;

#if HSCRIPT_ALLOWED
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
		if (PlayState.instance != null)
			PlayState.instance.addTextToDebug(details, 0xFFBB0000);
		return details;
	}

	/**
	 * Gets a scripted macro class created by the scripted class macro i made.
	 */
	@:noUsing public static inline function fromMacro(className:String)
		return Type.resolveClass('${className}${rulescript.macro.RuleScriptedMacro.CUSTOM_CLASSES_SHADOW_SUFFIX}');

	public static function tryParseModule(code:String):Array<ModuleDecl>
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
		try
		{
			var path:Array<String> = name.split('.');

			var pack:Array<String> = [];

			while (path[0].charAt(0) == path[0].charAt(0).toLowerCase())
				pack.push(path.shift());

			var moduleName:String = null;

			if (path.length > 1)
				moduleName = path.shift();

			final packName = '${(pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]).replace('.', '/')}.hx'; // if ?? doesn't work use a newer version of haxe
			final filePath = 'scripts/$packName';

			#if MODS_ALLOWED
			for (mod in (Mods.parseList().enabled).concat(['']))
			{
				final modPath:String = Paths.mods(mod + '/$filePath');
				if (FileSystem.exists(modPath))
					return tryParseModule(File.getContent(modPath));
			}
			#end

			// Check file.
			var full = Paths.getSharedPath() + filePath;
			if (!FileSystem.exists(full))
				return null;
			return tryParseModule(File.getContent(full));
		}
		catch (e)
		{
			Logs.error(e);
			return null;
		}
	}
}
#end