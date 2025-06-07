#if HSCRIPT_ALLOWED
package funkin.backend.system.scripts;

/**
* Modifed Interp to allow scripts ot access class vairables without using FlxG.state or other lesser methods.	
*/
class RuleScriptInterpreter extends RuleScriptInterp
{
	@:dox(hide) override function resolve(id:String):Dynamic
	{
		// THIS & SUPER KEYWORDS
		if (id == 'this') return this;
		if (id == 'super' && superInstance != null) return superInstance;

		// LOCALS
		final l:Dynamic = locals.get(id);
		if (l != null) return getScriptProp(l.r);

		// VARIABLES
		var v:Dynamic = null;
		v = getScriptProp(variables.get(id));
		if (v == null && !variables.exists(id))
			v = Reflect.getProperty(superInstance, id) ?? error(EUnknownVariable(id));
		return v;

		// IMPORTS
		var i:Dynamic = null;
		i = getScriptProp(imports.get(id));
		if(i == null && !imports.get(id))
			i = Reflect.getProperty(superInstance, id) ?? error(EUnknownVariable(id));
		return i;

		// UNKNOWN VARIABLE>>>
		error(EUnknownVariable(id));

		return null;
	}
}
#end
