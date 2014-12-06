package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
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
	
	private var _flipped:Bool = false;

	public function new(xp:Float, yp:Float) 
	{
		_xp = xp;
		_yp = yp;
	}
	override public function onAdded():Void {
		body = new Body();
		body.shapes.add(new Polygon(Polygon.box(GameConfig.playerWidth, GameConfig.playerHeight), new Material(0,0,0)));	// TODO dont allow rotate, mass
		body.position = Vec2.get(_xp, _yp);
		var entity:Entity = PlayModel.space.addBody(body);
		entity.add(sprite = new FillSprite(GameConfig.playerColour, GameConfig.playerWidth, GameConfig.playerHeight));
		sprite.centerAnchor();
		owner.addChild(entity);
		body.velocity = new Vec2(GameConfig.playerSpeed, 0);
	}
	override public function onUpdate(dt:Float):Void {
		checkPlayerCollision();
		
		
	}
	private function checkPlayerCollision():Void {
		if (Lambda.count(body.interactingBodies()) > 1) { flipVelocity(); }
	}
	private function flipVelocity():Void {		// not sure this hack will work with different delta times.... 
		_flipped = !_flipped;
		if (_flipped) {
			body.position.x -= 1;
			body.velocity.x = -GameConfig.playerSpeed;
		}else {
			body.position.x += 1;
			body.velocity.x = GameConfig.playerSpeed;
		}
	}
	
}