package urgame.scenes.play;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
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
	private var _collectLayer:Entity;
	private var _hazardLayer:Entity;
	private var _platformLayer:Entity;
	private var _playerLayer:Entity;
	private var _goalLayer:Entity;
	
	private var _player:Player;
	
	private var _isJumping:Bool = false;
	private var _isDragging:Bool = false;
	
	public function new() 
	{
		
	}
	override public function onAdded():Void {
		owner.addChild(new Entity().add(new FillSprite(GameConfig.bgColour, OliG.width, OliG.height)));	// bg
		owner.add(space = new SpaceComponent(1000));
		initLayers();
		addBorder();
		addPlayer();
		initInteraction();
	}
	
	private function initLayers():Void {
		owner.addChild(_borderLayer = new Entity());
		owner.addChild(_collectLayer = new Entity());
		owner.addChild(_hazardLayer = new Entity());
		owner.addChild(_platformLayer = new Entity());
		owner.addChild(_playerLayer = new Entity());
		owner.addChild(_goalLayer = new Entity());
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
			var pos:Vec2 = Vec2.get(Viewport.instance.getRelativeX(e.viewX), Viewport.instance.getRelativeY(e.viewY));
			if (VecFunc.getDistanceBetween(pos, _player.body.position) < GameConfig.playerTapRadius) {
				_isJumping = true;
				_player.jump();
			}else {
				_isDragging = true;
				//trace('tap elsewhere');
			}
		});
		System.pointer.up.connect(function(e:PointerEvent):Void {
			if (_isJumping) {
				_isJumping = false;
				_player.stopJump();
			}else {
				_isDragging = false;
				//trace('stop dragging');
			}
		});
	}
}