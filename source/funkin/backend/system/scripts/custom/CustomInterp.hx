package funkin.backend.system.scripts.custom;
#if HSCRIPT_ALLOWED
class CustomInterp extends crowplexus.hscript.Interp
{
	public var parentInstance:Dynamic;
	public function new()
	{
		super();
	}

	override function resolve(id: String): Dynamic {
		if (locals.exists(id)) {
			var l = locals.get(id);
			return l.r;
		}

		if (variables.exists(id)) {
			var v = variables.get(id);
			return v;
		}

		if (imports.exists(id)) {
			var v = imports.get(id);
			return v;
		}

		if(parentInstance != null && Type.getInstanceFields(Type.getClass(parentInstance)).contains(id)) {
			var v = Reflect.getProperty(parentInstance, id);
			return v;
		}

		error(EUnknownVariable(id));

		return null;
	}
}
#end