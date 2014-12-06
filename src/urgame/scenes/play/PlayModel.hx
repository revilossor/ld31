package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Rectangle;
import flambe.System;
import nape.geom.Vec2;
import oli.nape.SpaceComponent;
import oli.util.OliG;
import oli.util.VecFunc;
import oli.Viewport;
import urgame.scenes.play.comp.RectBody;

/**
 * ...
 * @author Oliver Ross
 */
class PlayModel extends Component
{	
	public static var space:SpaceComponent;
	
	private var _borderLayer:Entity;
	private var _drawingLayer:Entity;
	private var _collectLayer:Entity;
	private var _hazardLayer:Entity;
	private var _platformLayer:Entity;
	private var _playerLayer:Entity;
	private var _goalLayer:Entity;
	
	private var _player:Player;
	
	private var _isJumping:Bool = false;
	private var _isDragging:Bool = false;
	
	private var _startDragPoint:Vec2;
	private var _tempRect:FillSprite;
	
	private var _playerInTempRect:Bool = false;
	private var _tempRectTooSmall:Bool = false;
	
	public function new() 
	{
		
	}
	override public function onAdded():Void {
		Viewport.instance.fadeIn(0x000000, 1);
		owner.addChild(new Entity().add(new FillSprite(GameConfig.bgColour, OliG.width, OliG.height)));	// bg
		owner.add(space = new SpaceComponent(1000));
		initLayers();
		//initTempRect();
		addBorder();
		addPlayer();
		initInteraction();
		//initGoal();
	}
	private function initLayers():Void {
		owner.addChild(_borderLayer = new Entity());
		owner.addChild(_drawingLayer = new Entity());
		owner.addChild(_collectLayer = new Entity());
		owner.addChild(_hazardLayer = new Entity());
		owner.addChild(_platformLayer = new Entity());
		owner.addChild(_playerLayer = new Entity());
		owner.addChild(_goalLayer = new Entity());
	}
	private function initTempRect():Void {
		_drawingLayer.addChild(new Entity().add(_tempRect = new FillSprite(0xffffff, 0, 0)));
	}
	private function addBorder():Void {
		_borderLayer.add(new RectBody(0, 0, GameConfig.borderWidth, OliG.height, GameConfig.borderColour));
		_borderLayer.add(new RectBody(OliG.width - GameConfig.borderWidth, 0, GameConfig.borderWidth, OliG.height, GameConfig.borderColour));
		_borderLayer.add(new RectBody(GameConfig.borderWidth, 0, OliG.width - GameConfig.borderWidth * 2, GameConfig.borderWidth, GameConfig.borderColour));
		_borderLayer.add(new RectBody(GameConfig.borderWidth, OliG.height - GameConfig.borderWidth, OliG.width - GameConfig.borderWidth * 2, GameConfig.borderWidth, GameConfig.borderColour));
	}
	private function addPlayer():Void {
		_playerLayer.add(_player = new Player(100, 100));
	}
	private function initInteraction():Void {
		System.pointer.down.connect(function(e:PointerEvent):Void {
			var startpos:Vec2 = Vec2.get(Viewport.instance.getRelativeX(e.viewX), Viewport.instance.getRelativeY(e.viewY), true);
			if (VecFunc.getDistanceBetween(startpos, _player.body.position) < GameConfig.playerTapRadius) {
				_isJumping = true;
				_player.jump();
			}else {
				startDrag(startpos);
			}
		});
		System.pointer.up.connect(function(e:PointerEvent):Void {
			if (_isJumping) {
				_isJumping = false;
				_player.stopJump();
			}else if(_isDragging) {
				endDrag();
			}
		});
		System.pointer.move.connect(function(e:PointerEvent):Void {
			if (_isDragging) {
				getRectFromPoints(Vec2.get(Viewport.instance.getRelativeX(e.viewX), Viewport.instance.getRelativeY(e.viewY), true));
			}
		});
	}
	private function startDrag(startpos:Vec2):Void {
		_startDragPoint = startpos;
		_isDragging = true;
		initTempRect();
	}
	private function endDrag():Void {
		_isDragging = false;
		//if(_tempRect != null){
		trace('relaese');
			addPlatform(_tempRect.x._, _tempRect.y._, _tempRect.width._, _tempRect.height._);
		//}
		_drawingLayer.disposeChildren();
	}
	private function getRectFromPoints(endpoint:Vec2) {
		var between:Vec2 = VecFunc.getBetween(_startDragPoint, endpoint);
		var xp:Float = 0, yp:Float = 0, width:Float = 0, height:Float = 0;
		if (_startDragPoint.x < endpoint.x && _startDragPoint.y < endpoint.y) {
			xp =_startDragPoint.x; yp = _startDragPoint.y; width = Math.abs(between.x); height = Math.abs(between.y);
		}else if (_startDragPoint.x < endpoint.x && _startDragPoint.y > endpoint.y) {
			xp = _startDragPoint.x; yp =  endpoint.y; width =  Math.abs(between.x); height = Math.abs(between.y);
		}else if (_startDragPoint.x > endpoint.x && _startDragPoint.y < endpoint.y) {
			xp = endpoint.x; yp =  _startDragPoint.y; width =  Math.abs(between.x); height = Math.abs(between.y);
		}else if (_startDragPoint.x > endpoint.x && _startDragPoint.y > endpoint.y) {
			xp = endpoint.x; yp =  endpoint.y; width =  Math.abs(between.x); height = Math.abs(between.y);
		}
		//if (xp != 0 && yp != 0 && width != 0 && height != 0) {
			updateTempRect(xp, yp, width, height);
		//}
	}
	private function updateTempRect(xp:Float, yp:Float, width:Float, height:Float):Void {
		_drawingLayer.disposeChildren();
		var error:Bool = false;
		_tempRectTooSmall = (width < GameConfig.minimumPlatformSize || height < GameConfig.minimumPlatformSize);
		if (_tempRectTooSmall || _playerInTempRect) { error = true; }
		_tempRect = new FillSprite(error?GameConfig.tempRectErrorColour:GameConfig.tempRectColour, width, height);
		_tempRect.alpha._ = GameConfig.tempRectAlpha;
		_tempRect.setXY(xp, yp);
		_drawingLayer.addChild(new Entity().add(_tempRect));
	}
	private function addPlatform(xp:Float, yp:Float, width:Float, height:Float):Void {
		trace('add w : $width h $height x $xp y $yp');
		if (_tempRectTooSmall || _playerInTempRect) { return; }
		if (xp == 0 || yp == 0 || width == 0 || height == 0) { return; }
		_platformLayer.add(new RectBody(xp, yp, width, height, GameConfig.platformColour));
		trace('...done');
	}
	private function isPlayerInRect(rect:Rectangle):Bool {
		//trace('player y ' + _player.sprite.y._ + ' rect bottom : ' + rect.bottom); 
		if ((_player.sprite.y._ - _player.sprite.getNaturalHeight() / 2 < rect.bottom) && (_player.sprite.y._ + _player.sprite.getNaturalHeight() / 2 > rect.top)) {
			if ((_player.sprite.x._ - _player.sprite.getNaturalWidth() / 2 < rect.right) && (_player.sprite.x._ + _player.sprite.getNaturalWidth() /2 > rect.left)) {
				return true;
			}
		}
		if ((_player.sprite.x._ - _player.sprite.getNaturalWidth() / 2 < rect.right) && (_player.sprite.x._ + _player.sprite.getNaturalWidth() / 2 > rect.left)) {
			if ((_player.sprite.y._ - _player.sprite.getNaturalHeight() / 2 < rect.bottom) && (_player.sprite.y._ + _player.sprite.getNaturalHeight() / 2 > rect.top)) {
				return true;
			}
		}
		return false;
	}
	override public function onUpdate(dt:Float):Void {
		if(_tempRect!= null){
			_playerInTempRect =	isPlayerInRect(new Rectangle(_tempRect.x._, _tempRect.y._, _tempRect.getNaturalWidth(), _tempRect.getNaturalHeight()));
		}
	}

	
	
	
}