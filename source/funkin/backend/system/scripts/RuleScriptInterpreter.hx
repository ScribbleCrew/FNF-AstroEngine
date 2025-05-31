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
	public var parent(default, set):Dynamic = [];
	@:dox(hide) @:noCompletion function set_parent(instance:Dynamic):Dynamic
	{
		parent = instance;
		_instanceFields = parent == null ? [] : Type.getInstanceFields(Type.getClass(instance));
		return instance;
	}

	@:dox(hide) override function resolve(id:String):Dynamic
	{
		if (locals.exists(id))// local variables first
			return locals.get(id).r;

		if (variables.exists(id)) // set variables seconds
			return variables.get(id);

		if (imports.exists(id)) // import variables third
			return imports.get(id);

		if (parent != null && _instanceFields.contains(id)) // parent variables fourth.
			return Reflect.getProperty(parent, id);

		error(EUnknownVariable(id));

		return null;
	}
}
#end
