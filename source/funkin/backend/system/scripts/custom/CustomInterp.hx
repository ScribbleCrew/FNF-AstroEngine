package funkin.backend.system.scripts.custom;

#if HSCRIPT_ALLOWED
class CustomInterp extends crowplexus.hscript.Interp
{
	public var parentInstance:Dynamic;

	public function new()
	{
		super();
	}

	override function resolve(id:String):Dynamic
	{
		if (locals.exists(id))
			return locals.get(id).r;

		if (variables.exists(id))
			return variables.get(id);

		if (imports.exists(id))
			return imports.get(id);

		if (parentInstance != null && Type.getInstanceFields(Type.getClass(parentInstance)).contains(id))
			return Reflect.getProperty(parentInstance, id);

		try {//hmm
			final cls = Type.resolveClass(id);
			if (cls != null) return cls;
		} catch (e:Dynamic) {}

		error(EUnknownVariable(id));

		return null;
	}
}
#end
