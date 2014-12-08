package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.Rectangle;
import flambe.swf.Flipbook;
import flambe.swf.Library;
import flambe.swf.MovieSprite;
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
import oli.OliGameContext;

/**
 * ...
 * @author Oliver Ross
 */
class Player extends Component
{
	private var _xp:Float;
	private var _yp:Float;
	
	public var body:Body;
	public var sprite:Sprite; 
	
	private var _flipped:Bool = false;

	private var _numInteracting:Int = 0;
	
	private var _isJumping:Bool = false;
	private var _jumpCounter:Int = 0;
	
	private var _touchingBottom:Bool = false;
	private var _touchingTop:Bool = false;
	private var _touchingLeft:Bool = false;
	private var _touchingRight:Bool = false;
	
	private var _runLeft:MovieSprite;
	private var _runRight:MovieSprite;
	private var _jumpLeft:MovieSprite;
	private var _jumpRight:MovieSprite;
	
	private var _entity:Entity;
	
	public function new(xp:Float, yp:Float) 
	{
		_xp = xp;
		_yp = yp;
	}
	override public function onAdded():Void {
		initLib();
		body = new Body();
		body.shapes.add(new Polygon(Polygon.box(GameConfig.playerWidth, GameConfig.playerHeight), new Material(0,0,0)));
		body.position = Vec2.get(_xp, _yp, true);
		body.allowRotation = false;
		_entity = PlayModel.space.addBody(body);
		_entity.add(sprite = _runRight);
		sprite.centerAnchor();
		owner.addChild(_entity);
		body.velocity = Vec2.get(GameConfig.playerSpeed, 0, true);
	}
	
	private function initLib():Void {
		var _lib:Library = Library.fromFlipbooks([
			new Flipbook('runleft', OliGameContext.instance.assets.getTexture('play/player-walk-left').split(2))
				.setDuration(GameConfig.playerRuncycleDuration).setAnchor(5,7),
			new Flipbook('runright', OliGameContext.instance.assets.getTexture('play/player-walk-right').split(2))
				.setDuration(GameConfig.playerRuncycleDuration).setAnchor(5,7),
			new Flipbook('jumpleft', OliGameContext.instance.assets.getTexture('play/player-jump-left').split(1)).setAnchor(5,7),
			new Flipbook('jumpright', OliGameContext.instance.assets.getTexture('play/player-jump-right').split(1)).setAnchor(5,7)
		]);
		_runLeft = _lib.createMovie('runleft');
		_runRight = _lib.createMovie('runright');
		_jumpLeft = _lib.createMovie('jumpleft');
		_jumpRight = _lib.createMovie('jumpright');
	}
	private function play(to:MovieSprite):Void {
		_entity.add(to);
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
		
		
		if (_isJumping || _numInteracting == 0) {
			if (body.velocity.x < 0) {
				play(_jumpLeft);
			}else {
				play(_jumpRight);
			}
		}else if (body.velocity.x < 0) {
			play(_runLeft);
		}else {
			play(_runRight);
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
			OliGameContext.instance.assets.getSound('jump').play(0.1);
			_isJumping = true;
			body.applyImpulse(Vec2.get(0, -GameConfig.playerJumpInitial, true));
		}
	}
	public function stopJump():Void {
		_isJumping = false;
		_jumpCounter = 0;
	}
}