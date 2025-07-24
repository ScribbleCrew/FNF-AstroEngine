package rulescript;

import funkin.modding.Script;
import haxe.extern.EitherType;
import hscript.Expr;
import rulescript.interps.RuleScriptInterp;
import rulescript.parsers.HxParser;
import rulescript.parsers.Parser;
import rulescript.types.ScriptedTypeUtil;
// TODO::: COMBINE THIS AND HSCRIPT.HX
class RuleScript extends Script
{
	@:deprecated('`resolveScript` is deprecated, use `ScriptedTypeUtil.resolveScript`')
	public static var resolveScript(get, set):String->Dynamic;

	static function get_resolveScript():String->Dynamic
	{
		return ScriptedTypeUtil.resolveScript;
	}

	static function set_resolveScript(v:String->Dynamic):String->Dynamic
	{
		return ScriptedTypeUtil.resolveScript = v;
	}

	public static dynamic function createInterp():IInterp
	{
		return new RuleScriptInterp();
	}

	/**
	 * Functions similarly to import.hx (https://haxe.org/manual/type-system-import-defaults.html).
	 * 
	 * Package => Types.
	 */
	public static var defaultImports:Map<String, Map<String, Dynamic>> = [
		'' => [
			#if hl
			'Std' => rulescript.std.hl.Std, 'Math' => rulescript.std.hl.Math, 'Reflect' => rulescript.std.hl.Reflect,
			#else
			'Reflect' => Reflect, 'Std' => Std, 'Math' => Math,
			#end
			'Type' => Type,
			'StringTools' => StringTools,
			'Date' => Date,
			'DateTools' => DateTools,
			'Xml' => Xml,
			#if sys 'Sys' => Sys #end
		]
	];

	public var interp(default, set):IInterp;

	public var access:RuleScriptAccess;

	public var scriptName(get, set):String;

	public var scriptPackage(get, set):String;

	public var superInstance(get, set):Dynamic;

	public var variables(get, set):Map<String, Dynamic>;

	public var parser:Parser;

	public var hasErrorHandler(get, set):Bool;

	public var errorHandler(get, set):haxe.Exception->Void;

	public var context(get, set):Context;

	public function new(?interp:IInterp, ?parser:Parser, ?context:Context)
	{
		super();
		
		// You can register custom parser in a child class
		this.interp ??= interp ?? createInterp();
		this.parser ??= parser ?? new HxParser();

		if (context != null)
			this.context = context;
	}

	public function execute(code:EitherType<String, Expr>):Dynamic
	{
		return access.execute(code is String ? parser.parse(cast code) : cast code);
	}

	public function tryExecute(code:EitherType<String, Expr>, ?customCatch:haxe.Exception->Dynamic):Dynamic
	{
		return try
		{
			execute(code);
		}
		catch (v)
			customCatch != null ? customCatch(v) : v.details();
	}

	public function getParser<T:Parser>(?parserClass:Class<T>):T
	{
		return cast parser;
	}

	public function getInterp<T:IInterp>(?interpClass:Class<T>):T
	{
		return cast interp;
	}

	function set_interp(v:IInterp):IInterp
	{
		access = v.access;
		return interp = v;
	}

	function get_scriptName():String
	{
		return access.scriptName;
	}

	function set_scriptName(v:String):String
	{
		return access.scriptName = v;
	}

	function get_scriptPackage():String
	{
		return access.scriptPackage;
	}

	function set_scriptPackage(v:String):String
	{
		return access.scriptPackage = v;
	}

	function get_superInstance():Dynamic
	{
		return access.superInstance;
	}

	function set_superInstance(v:Dynamic):Dynamic
	{
		return access.superInstance = v;
	}

	function get_variables():Map<String, Dynamic>
	{
		return access.getVariables();
	}

	function set_variables(v:Map<String, Dynamic>):Map<String, Dynamic>
	{
		return access.setVariables(v);
	}

	function get_hasErrorHandler():Bool
	{
		return access.hasErrorHandler;
	}

	function set_hasErrorHandler(v:Bool):Bool
	{
		return access.hasErrorHandler = v;
	}

	function get_errorHandler():haxe.Exception->Void
	{
		return access.errorHandler;
	}

	function set_errorHandler(v:haxe.Exception->Void):haxe.Exception->Void
	{
		return access.errorHandler = v;
	}

	function get_context():Dynamic
	{
		return access.context;
	}

	function set_context(v:Dynamic):Dynamic
	{
		return access.context = v;
	}
}

interface IInterp
{
	var access:RuleScriptAccess;
}
