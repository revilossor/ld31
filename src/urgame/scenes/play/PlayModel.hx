package urgame.scenes.play;
import flambe.animation.Ease;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Rectangle;
import flambe.System;
import nape.geom.Vec2;
import oli.nape.SpaceComponent;
import oli.OliGameContext;
import oli.util.OliG;
import oli.util.VecFunc;
import oli.Viewport;
import urgame.scenes.play.comp.GoalComponent;
import urgame.scenes.play.comp.RectBody;
import urgame.scenes.summary.SummaryScene;

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
	private var _allPlatforms:Array<RectBody> = new Array<RectBody>();
	
	private var _isJumping:Bool = false;
	private var _isDragging:Bool = false;
	
	private var _startDragPoint:Vec2;
	private var _tempRect:FillSprite;
	
	private var _playerInTempRect:Bool = false;
	private var _goalInTempRect:Bool = false;
	private var _platformInTempRect:Bool = false;
	private var _tempRectTooSmall:Bool = false;
	private var _tempRectOffscreen:Bool = false;
	
	private var _goal:GoalComponent;
	
	private var _progressTable:Map<String, Dynamic>;
	
	private var _jumps:Int = 0;
	private var _time:Int = 0;
	
	public function new(data:Map<String, Dynamic> = null) 
	{
		data == null?_progressTable = new Map<String, Dynamic>():_progressTable = data;
		_progressTable.set(GameConfig.PLATFORMS, new Array<Dynamic>());
		_progressTable.set(GameConfig.TIME_TAKEN, 0);
		_progressTable.set(GameConfig.JUMPS, 0);
		_progressTable.set(GameConfig.SCREEN_AREA, 0);
	}
	override public function onAdded():Void {
		Viewport.instance.fadeIn(0x000000, 1);
		owner.addChild(new Entity().add(new FillSprite(GameConfig.bgColour, OliG.width, OliG.height)));	// bg
		owner.add(space = new SpaceComponent(1000));
		initLayers();
		addBorder();
		addPlayer();
		initInteraction();
		initGoal();
	}
	private function initLayers():Void {
		owner.addChild(_borderLayer = new Entity());
		owner.addChild(_drawingLayer = new Entity());
		owner.addChild(_collectLayer = new Entity());
		owner.addChild(_hazardLayer = new Entity());
		owner.addChild(_platformLayer = new Entity());
		owner.addChild(_goalLayer = new Entity());
		owner.addChild(_playerLayer = new Entity());
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
			if (VecFunc.getDistanceBetween(startpos, _player.body.position) < GameConfig.playerTapRadius && !_isJumping) {
				_isJumping = true;
				_player.jump();
			}else {
				startDrag(startpos);
			}
		});
		System.pointer.up.connect(function(e:PointerEvent):Void {
			if (_isJumping) {
				_jumps++;					// TODO can increment this when in air... move to player???
				trace('jumps $_jumps');
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
	private function initGoal():Void {
		_goalLayer.add(_goal = new GoalComponent(GameConfig.goalX, GameConfig.goalY));
		var rect:RectBody = new RectBody(GameConfig.goalX - 5, GameConfig.goalY + 15, 25, 5, GameConfig.goalPlatformColour);
		_platformLayer.add(rect);
		_allPlatforms.push(rect);
	}
	private function startDrag(startpos:Vec2):Void {
		if (startpos.x < 0 || startpos.x > OliG.width || startpos.y < 0 || startpos.y > OliG.height) { trace('offscreen start!'); return; }
		_startDragPoint = startpos;
		_isDragging = true;
		initTempRect();
	}
	private function endDrag():Void {
		_isDragging = false;
		addPlatform(_tempRect.x._, _tempRect.y._, _tempRect.width._, _tempRect.height._);
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
		_tempRectOffscreen = (endpoint.x < 0 || endpoint.x > OliG.width || endpoint.y < 0 || endpoint.y > OliG.height);
		updateTempRect(xp, yp, width, height);
	}
	private function updateTempRect(xp:Float, yp:Float, width:Float, height:Float):Void {
		_drawingLayer.disposeChildren();
		var error:Bool = false;
		_tempRectTooSmall = (width < GameConfig.minimumPlatformSize || height < GameConfig.minimumPlatformSize);
		if (_tempRectTooSmall || _playerInTempRect || _tempRectOffscreen || _goalInTempRect || _platformInTempRect) { error = true; }
		_tempRect = new FillSprite(error?GameConfig.tempRectErrorColour:GameConfig.tempRectColour, width, height);
		_tempRect.alpha._ = GameConfig.tempRectAlpha;
		_tempRect.setXY(xp, yp);
		_drawingLayer.addChild(new Entity().add(_tempRect));
	}
	private function addPlatform(xp:Float, yp:Float, width:Float, height:Float):Void {
		if (_tempRectTooSmall || _playerInTempRect || _tempRectOffscreen || _goalInTempRect || _platformInTempRect) { return; }
		if (xp == 0 || yp == 0 || width == 0 || height == 0) { return; }
		addRectBody(xp, yp, width, height, GameConfig.platformColour);
		updateArea(width, height);
	}
	private function addRectBody(xp:Float, yp:Float, width:Float, height:Float, colour:Int):Void {
		var rect:RectBody = new RectBody(xp, yp, width, height, colour);
		_platformLayer.add(rect);
		_allPlatforms.push(rect);
		addPlatformToProgressList(rect);
	}
	private function isPlayerInRect(rect:Rectangle):Bool {
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
	private function isGoalInRect(rect:Rectangle):Bool {
		if ((_goal.rect.top < rect.bottom) && (_goal.rect.bottom > rect.top)) {
			if ((_goal.rect.left < rect.right) && (_goal.rect.right > rect.left)) {
				return true;
			}
		}
		if ((_goal.rect.left < rect.right) && (_goal.rect.right > rect.left)) {
			if ((_goal.rect.top < rect.bottom) && (_goal.rect.bottom > rect.top)) {
				return true;
			}
		}
		return false;
	}
	private function areAnyPlatformsInRect(rect:Rectangle):Bool {
		for (platform in _allPlatforms) {
			var plat:Rectangle = platform.rect;
			if ((plat.top < rect.bottom) && (plat.bottom > rect.top)) {
				if ((plat.left < rect.right) && (plat.right > rect.left)) {
					return true;
				}
			}
			if ((plat.left < rect.right) && (plat.right > rect.left)) {
				if ((plat.top < rect.bottom) && (plat.bottom > rect.top)) {
					return true;
				}
			}
		}
		return false;
	}
	override public function onUpdate(dt:Float):Void {
		if (_tempRect != null) {
			var rect:Rectangle = new Rectangle(_tempRect.x._, _tempRect.y._, _tempRect.getNaturalWidth(), _tempRect.getNaturalHeight());
			_playerInTempRect =	isPlayerInRect(rect);
			_goalInTempRect =	isGoalInRect(rect);
			_platformInTempRect =	areAnyPlatformsInRect(rect);
		}
		if (VecFunc.distanceCheck(_player.body.position, _goal.position, 10)) {
			_player.body.velocity = Vec2.get();
			_player.sprite.alpha.animateTo(0, 1, Ease.circOut);
			Viewport.instance.fadeOut(0x000000, 1, function():Void {
				updateTime();
				updateJumps();
				updatePlatformsPlaced();
				OliGameContext.instance.director.unwindToScene(SummaryScene.create(_progressTable));		//TODO difficulty
			});
		}
		_time++;
	}
	
	private function updatePlatformsPlaced():Void {
		var gameplatformasplaced:Int = _progressTable.get(GameConfig.GAME_PLATFORMS_PLACED);
		if (gameplatformasplaced == null) { gameplatformasplaced = 0; }
		gameplatformasplaced += (Lambda.count(_allPlatforms) - 1);
		_progressTable.set(GameConfig.GAME_PLATFORMS_PLACED, gameplatformasplaced);
	}
	private function updateTime():Void {
		var currentLevelTime:Int = _progressTable.get(GameConfig.TIME_TAKEN);
		if (currentLevelTime == null) { currentLevelTime = 0; }
		currentLevelTime += _time;
		_progressTable.set(GameConfig.TIME_TAKEN, currentLevelTime);		// div 60 for seconds
		var gametime:Int = _progressTable.get(GameConfig.GAME_TIME_TAKEN);
		if (gametime == null) { gametime = 0; }
		_progressTable.set(GameConfig.GAME_TIME_TAKEN, (gametime + currentLevelTime));
	}
	private function updateJumps():Void {
		var jumpstaken:Int = _progressTable.get(GameConfig.JUMPS);
		if (jumpstaken == null) { jumpstaken = 0; }
		jumpstaken += _jumps;
		_progressTable.set(GameConfig.JUMPS, jumpstaken);
		var gamejumps:Int = _progressTable.get(GameConfig.GAME_JUMPS);
		if (gamejumps == null) { gamejumps = 0; }
		_progressTable.set(GameConfig.GAME_JUMPS, (gamejumps + jumpstaken));
	}
	private inline function getAreaOfPlatform(width:Float, height:Float):Float {
		return Math.ceil((width * height / GameConfig.playArea)*100);									
	}
	private function updateArea(width:Float, height:Float) {
		var currentScreenArea:Float = _progressTable.get(GameConfig.SCREEN_AREA);
		if (currentScreenArea == null) { currentScreenArea = 0; }
		var areaOfThisPlatform:Float = getAreaOfPlatform(width, height);
		_progressTable.set(GameConfig.SCREEN_AREA, (currentScreenArea + areaOfThisPlatform));
		var totalgamearea:Float = _progressTable.get(GameConfig.TOTAL_GAME_AREA);
		if (totalgamearea == null) { totalgamearea = 0; }
		totalgamearea += areaOfThisPlatform;
		_progressTable.set(GameConfig.TOTAL_GAME_AREA, totalgamearea);
	}
	private function addPlatformToProgressList(platform:RectBody):Void {
		var currentPlatforms:Array<Dynamic> = _progressTable.get(GameConfig.PLATFORMS);
		if (currentPlatforms == null) { currentPlatforms = new Array<Dynamic>(); };
		var platformData:Dynamic = getPlatformData(platform);
		currentPlatforms.push(platformData);
		_progressTable.set(GameConfig.PLATFORMS, currentPlatforms);
	}
	private function getPlatformData(platform:RectBody):Dynamic {
		var area:Float = getAreaOfPlatform(platform.sprite.getNaturalWidth(), platform.sprite.getNaturalHeight());
		var midpoint:Vec2 = Vec2.get(platform.sprite.x._ + platform.sprite.getNaturalHeight() / 2, platform.sprite.y._ + platform.sprite.getNaturalWidth() / 2);
		var dimensions:Vec2 = Vec2.get(platform.sprite.getNaturalHeight(), platform.sprite.getNaturalWidth());
		var position:Vec2 = Vec2.get(platform.sprite.x._, platform.sprite.y._);
		var orientation:String = platform.sprite.getNaturalHeight() > platform.sprite.getNaturalWidth()?GameConfig.VERTICAL:GameConfig.HORIZONTAL;
		return { area:cast area, midpoint:cast midpoint, orientation: cast orientation, position: cast position, dimensions : cast dimensions }
	}
}