package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.math.Rectangle;
import flambe.System;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.shape.ShapeList;

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

	private var _numInteracting:Int = 0;
	
	private var _isJumping:Bool = false;
	private var _jumpCounter:Int = 0;
	
	private var _touchingBottom:Bool = false;
	private var _touchingTop:Bool = false;
	private var _touchingLeft:Bool = false;
	private var _touchingRight:Bool = false;
	
	public function new(xp:Float, yp:Float) 
	{
		_xp = xp;
		_yp = yp;
	}
	override public function onAdded():Void {
		body = new Body();
		body.shapes.add(new Polygon(Polygon.box(GameConfig.playerWidth, GameConfig.playerHeight), new Material(0,0,0)));
		body.position = Vec2.get(_xp, _yp, true);
		body.allowRotation = false;
		var entity:Entity = PlayModel.space.addBody(body);
		entity.add(sprite = new FillSprite(GameConfig.playerColour, GameConfig.playerWidth, GameConfig.playerHeight));
		sprite.centerAnchor();
		owner.addChild(entity);
		body.velocity = Vec2.get(GameConfig.playerSpeed, 0, true);
	}
	override public function onUpdate(dt:Float):Void {
		checkPlayerCollision();
		
		if(_numInteracting >= 1){ _flipped?body.velocity.x = -GameConfig.playerSpeed:body.velocity.x = GameConfig.playerSpeed;}
		
		if (System.pointer.isDown() && _isJumping) {
			if (_jumpCounter++ > GameConfig.playerJumpDuration) {
				stopJump();
			}else{
				body.applyImpulse(Vec2.get(0, -GameConfig.playerJumpHold, true));
			}
		}
		
	}
	private function checkPlayerCollision():Void {
		var ib:BodyList = body.interactingBodies();
		_numInteracting = Lambda.count(ib);
		if (_numInteracting > 1) { flipVelocity(); }
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
	public function jump():Void {
		if (_isJumping == false && _numInteracting >= 1) {
			_isJumping = true;
			body.applyImpulse(Vec2.get(0, -GameConfig.playerJumpInitial, true));
		}
	}
	public function stopJump():Void {
		_isJumping = false;
		_jumpCounter = 0;
	}
}