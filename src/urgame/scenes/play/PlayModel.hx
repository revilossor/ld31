package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import oli.util.OliG;

/**
 * ...
 * @author Oliver Ross
 */
class PlayModel extends Component
{
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
		owner.addChild(new Entity().add(new FillSprite(0xff00ff, OliG.width, OliG.height)));	// bg
		initLayers();
	}
	
	private function initLayers() {
		owner.addChild(_borderLayer = new Entity());
		owner.addChild(_collectLayer = new Entity());
		owner.addChild(_hazardLayer = new Entity());
		owner.addChild(_platformLayer = new Entity());
		owner.addChild(_playerLayer = new Entity());
		owner.addChild(_goalLayer = new Entity());
	}
	
}