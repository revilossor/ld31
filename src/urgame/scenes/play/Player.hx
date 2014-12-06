package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Polygon;

/**
 * ...
 * @author Oliver Ross
 */
class Player extends Component
{
	private var _xp:Float;
	private var _yp:Float;
	
	public var body:Body;
	public var sprite:FillSprite;
	
	public function new(xp:Float, yp:Float) 
	{
		_xp = xp;
		_yp = yp;
	}
	override public function onAdded():Void {
		body = new Body();
		body.shapes.add(new Polygon(Polygon.box(GameConfig.playerWidth, GameConfig.playerHeight), Material.wood()));	// TODO dont allow rotate, mass
		body.position = Vec2.get(_xp, _yp);
		var entity:Entity = PlayModel.space.addBody(body);
		entity.add(sprite = new FillSprite(GameConfig.playerColour, GameConfig.playerWidth, GameConfig.playerHeight));
		sprite.centerAnchor();
		owner.addChild(entity);
		
	}
	
}