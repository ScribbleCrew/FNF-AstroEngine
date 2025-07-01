package funkin.backend.framerate.addons;

class EngineVersion extends FContainerField
{
	public var vers:TextField;
	public var versCycleBlah:TextField;

	public function new():Void
	{
		super();

		vers = new TextField();
		versCycleBlah = new TextField();

		for(v in [vers, versCycleBlah]) {
			v.autoSize = LEFT;
			v.x = v.y = 0;

			v.text = v == vers ? 'Astro Engine' : Main.releaseCycle;
			v.multiline = v.wordWrap = false;
			v.defaultTextFormat = new TextFormat(FramerateContainer.fontName, 12, -1);
			v.selectable = false;
			addChild(v);
		}

		versCycleBlah.alpha = 0.5;

		versCycleBlah.x = vers.x + vers.width;
	}
}
