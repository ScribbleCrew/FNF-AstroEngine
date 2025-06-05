#if HSCRIPT_ALLOWED
package funkin.backend.system.scripts;

/**
* Modifed Interp to allow scripts ot access class vairables without using FlxG.state or other lesser methods.	
*/
class RuleScriptInterpreter extends RuleScriptInterp
{
	@:dox(hide) private var _instanceFields:Array<String>;

	/**
	* The Parent Instance.
	* So we don't need to do `FlxG.state.<VAR>` to access state variables.
	*/
	public var parent(default, set):Array<String> = [];
	@:dox(hide) @:noCompletion function set_parent(instance:Dynamic):Array<String>
	{
		parent = instance;
		_instanceFields = (parent == null) ? [] : Type.getInstanceFields(Type.getClass(instance));
		return instance;
	}

	@:dox(hide) override function resolve(id:String):Dynamic
	{
		// local variables first
		if (locals.exists(id)) return locals.get(id).r;
		// set variables seconds
		if (variables.exists(id)) return variables.get(id);
		// import variables third
		if (imports.exists(id)) return imports.get(id);
		// parent variables fourth.
		if (parent != null && _instanceFields.contains(id)) return Reflect.getProperty(parent, id);

		error(EUnknownVariable(id));

		return null;
	}
}
#end
