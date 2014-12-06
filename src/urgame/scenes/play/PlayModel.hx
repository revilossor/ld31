package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import oli.nape.SpaceComponent;
import oli.util.OliG;
import urgame.scenes.play.comp.RectBody;

/**
 * ...
 * @author Oliver Ross
 */
class PlayModel extends Component
{	
	public static var space:SpaceComponent;
	
	private var _borderLayer:Entity;
	private var _collectLayer:Entity;
	private var _hazardLayer:Entity;
	private var _platformLayer:Entity;
	private var _playerLayer:Entity;
	private var _goalLayer:Entity;
	
	public function new() 
	{
		
	}
	override public function onAdded():Void {
		trace('onAdded');
		owner.addChild(new Entity().add(new FillSprite(GameConfig.bgColour, OliG.width, OliG.height)));	// bg
		owner.add(space = new SpaceComponent(1000));
		initLayers();
		addBorder();
	}
	private function initLayers() {
		owner.addChild(_borderLayer = new Entity());
		owner.addChild(_collectLayer = new Entity());
		owner.addChild(_hazardLayer = new Entity());
		owner.addChild(_platformLayer = new Entity());
		owner.addChild(_playerLayer = new Entity());
		owner.addChild(_goalLayer = new Entity());
	}
	private function addBorder() {
		_borderLayer.add(new RectBody(0, 0, GameConfig.borderWidth, OliG.height, GameConfig.borderColour));
		_borderLayer.add(new RectBody(OliG.width - GameConfig.borderWidth, 0, GameConfig.borderWidth, OliG.height, GameConfig.borderColour));
		_borderLayer.add(new RectBody(GameConfig.borderWidth, 0, OliG.width - GameConfig.borderWidth * 2, GameConfig.borderWidth, GameConfig.borderColour));
		_borderLayer.add(new RectBody(GameConfig.borderWidth, OliG.height - GameConfig.borderWidth, OliG.width - GameConfig.borderWidth * 2, GameConfig.borderWidth, GameConfig.borderColour));
		
		
		
	}
	
}