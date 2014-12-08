package urgame.scenes.play;
import flambe.animation.Ease;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Rectangle;
import flambe.System;
import nape.geom.AABB;
import nape.geom.Vec2;
import oli.nape.SpaceComponent;
import oli.OliGameContext;
import oli.util.OliG;
import oli.util.VecFunc;
import oli.Viewport;
import urgame.scenes.menu.MenuScene;
import urgame.scenes.play.comp.GoalComponent;
import urgame.scenes.play.comp.HazardComponent;
import urgame.scenes.play.comp.KeyCoponent;
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
	private var _uiLayer:Entity;
	
	private var _player:Player;
	private var _allPlatforms:Array<RectBody> = new Array<RectBody>();
	
	private var _isJumping:Bool = false;
	private var _isDragging:Bool = false;
	
	private var _startDragPoint:Vec2;
	private var _tempRect:FillSprite;
	
	private var _playerInTempRect:Bool = false;
	private var _goalInTempRect:Bool = false;
	private var _platformInTempRect:Bool = false;
	private var _keyInTempRect:Bool = false;
	private var _tempRectTooSmall:Bool = false;
	private var _tempRectOffscreen:Bool = false;
	
	private var _goal:GoalComponent;
	
	private var _progressTable:Map<String, Dynamic>;
	
	private var _jumps:Int = 0;
	private var _time:Int = 0;
	
	private var _numKeys:Int = 0;
	private var _allKeys:Array<KeyCoponent> = new Array<KeyCoponent>();
	private var _possKeyPos:Array<Dynamic>;
	
	private var _numHaz:Int = 0;
	private var _allHaz:Array<HazardComponent> = new Array<HazardComponent>();
	
	public function new(data:Map<String, Dynamic> = null, keys:Int = 0, haz = 0) 
	{
		data == null?_progressTable = new Map<String, Dynamic>():_progressTable = data;
		_numKeys = keys;
		_numHaz = haz;
		_possKeyPos = _progressTable.get(GameConfig.PLATFORMS);
		_progressTable.set(GameConfig.PLATFORMS, new Array<Dynamic>());
		_progressTable.set(GameConfig.TIME_TAKEN, 0);
		_progressTable.set(GameConfig.JUMPS, 0);
		_progressTable.set(GameConfig.SCREEN_AREA, 0);
	}
	override public function onAdded():Void {
		Viewport.instance.fadeIn(0x000000, 1);
		owner.addChild(new Entity().add(new ImageSprite(OliGameContext.instance.assets.getTexture('play/bg'))));	// bg
		owner.add(space = new SpaceComponent(1000));
		initLayers();
		addBorder();
		addPlayer();
		initInteraction();
		initGoal();
		initKeys();
		initHazards();
		initUI();
	}
	private function initLayers():Void {
		owner.addChild(_borderLayer = new Entity());
		owner.addChild(_drawingLayer = new Entity());
		owner.addChild(_collectLayer = new Entity());
		owner.addChild(_platformLayer = new Entity());
		owner.addChild(_goalLayer = new Entity());
		owner.addChild(_hazardLayer = new Entity());
		owner.addChild(_playerLayer = new Entity());
		owner.addChild(_uiLayer = new Entity());
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
		_playerLayer.add(_player = new Player(GameConfig.playerStartPos.x, GameConfig.playerStartPos.y));
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
	private function initKeys():Void {
		if(_numKeys > 0){
			//addKey(300, 100);
			_possKeyPos.sort(function(a, b):Int { return b.area - a.area; } );	
			var c:Int = _numKeys;
			for (plat in _possKeyPos) {
				if (c-- > 0) {
					var pos:Vec2 = cast plat.midpoint;
					addKey(pos.x, pos.y);
				}else {
					break;
				}
			}
			if (c > 0) {
				addKey(Math.random() * OliG.width, Math.random() * OliG.height);
			}
		}
	}
	private function addKey(xp:Float, yp:Float):Void {
		var key:KeyCoponent = new KeyCoponent(xp, yp);
		_hazardLayer.add(key);
		_allKeys.push(key);
	}
	private function initHazards():Void {
		for (h in 0 ... _numHaz) {
			addHaz();
		}
	}
	private function addHaz():Void {
		var haz:HazardComponent = new HazardComponent(40 + (Math.random() * (OliG.width - 50)), 40 + (Math.random() * (OliG.height - 50)));
		_hazardLayer.addChild(new Entity().add(haz));
		_allHaz.push(haz);
	}
	private function initUI():Void {
		var btn:ImageSprite = new ImageSprite(OliGameContext.instance.assets.getTexture('play/close'));
		btn.alpha._ = 0;
		btn.alpha.animateTo(0.3, 3, Ease.linear);
		btn.setXY(331, 3);
		btn.pointerIn.connect(function(e:PointerEvent):Void {
			btn.alpha.animateTo(0.8, 0.5, Ease.linear);
		});
		btn.pointerOut.connect(function(e:PointerEvent):Void {
			btn.alpha.animateTo(0.3, 0.5, Ease.linear);
		});
		btn.pointerUp.connect(function(e:PointerEvent):Void {
			OliGameContext.instance.assets.getSound('menu').play(0.3);
			Viewport.instance.fadeOut(0x000000, 1, function():Void {
				OliGameContext.instance.director.unwindToScene(MenuScene.create());
			});
		});
		_uiLayer.addChild(new Entity().add(btn));
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
		if (_tempRectTooSmall || _playerInTempRect || _tempRectOffscreen || _goalInTempRect || _platformInTempRect ||_keyInTempRect) { error = true; }
		_tempRect = new FillSprite(error?GameConfig.tempRectErrorColour:GameConfig.tempRectColour, width, height);
		_tempRect.alpha._ = GameConfig.tempRectAlpha;
		_tempRect.setXY(xp, yp);
		_drawingLayer.addChild(new Entity().add(_tempRect));
	}
	private function addPlatform(xp:Float, yp:Float, width:Float, height:Float):Void {
		if (_tempRectTooSmall || _playerInTempRect || _tempRectOffscreen || _goalInTempRect || _platformInTempRect || _keyInTempRect) { return; }
		if (xp == 0 || yp == 0 || width == 0 || height == 0) { return; }
		addRectBody(xp, yp, width, height, GameConfig.platformColour);
		updateArea(width, height);
		OliGameContext.instance.assets.getSound('place').play(0.2);
	}
	private function addRectBody(xp:Float, yp:Float, width:Float, height:Float, colour:Int):Void {
		var rect:RectBody = new RectBody(xp, yp, width, height, colour);
		_platformLayer.add(rect);
		_allPlatforms.push(rect);
		addPlatformToProgressList(rect);
	}
	private function isPlayerInRect(rect:Rectangle):Bool {
		var aabb:AABB = _player.body.bounds;
		var p:Rectangle = new Rectangle(aabb.x, aabb.y, aabb.width, aabb.height);
		if ((p.top < rect.bottom) && (p.bottom > rect.top)) {
			if ((p.left < rect.right) && (p.right > rect.left)) {
				return true;
			}
		}
		if ((p.left < rect.right) && (p.right> rect.left)) {
			if ((p.top < rect.bottom) && (p.bottom > rect.top)) {
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
	private function isPlayerOverDoor():Bool {
		var rect:Rectangle = _goal.rect;
		var aabb:AABB = _player.body.bounds;
		var p:Rectangle = new Rectangle(aabb.x, aabb.y, aabb.width, aabb.height);
		if ((p.top < rect.bottom) && (p.bottom > rect.top)) {
			if ((p.left < rect.right) && (p.right > rect.left)) {
				return true;
			}
		}
		if ((p.left < rect.right) && (p.right> rect.left)) {
			if ((p.top < rect.bottom) && (p.bottom > rect.top)) {
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
	private function areAnyKeysInRect(rect:Rectangle):Bool {
		for (key in _allKeys) {
			var plat:Rectangle = key.rect;
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
			_keyInTempRect =	areAnyKeysInRect(rect);
		}
		if (isPlayerOverDoor()) {
			if (Lambda.count(_allKeys) == 0 && !finished) {
				finished = true;
				_player.sprite.alpha.animateTo(0, 1, Ease.circOut);
				OliGameContext.instance.assets.getSound('door').play(0.2);
				Viewport.instance.fadeOut(0x000000, 1, function():Void {
					updateTime();
					updateJumps();
					updatePlatformsPlaced();
					OliGameContext.instance.director.unwindToScene(SummaryScene.create(_progressTable, _numKeys, _numHaz));
				});
			}else {
			}
		}
		if (finished) {
			_player.body.velocity = Vec2.get();
		}
		for (key in _allKeys) {
			if (VecFunc.distanceCheck(_player.body.position, key.getMidpoint(), GameConfig.keyDistanceThreshold)) {
				OliGameContext.instance.assets.getSound('key').play(0.4);
				key.remove();
				_allKeys.remove(key);
				break;
			}
		}
		for (bat in _allHaz) {
			if (isPlayerInRect(bat.getRect())) {
				_player.sprite.visible = false;
				OliGameContext.instance.assets.getSound('bat').play(0.1);
				Viewport.instance.fadeOut(0x000000, 0.5, function():Void {
					OliGameContext.instance.director.unwindToScene(DedScene.create());
				});
			}
		}
		_time++;
	}
	private var finished:Bool = false;
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
		return Math.ceil(((width * height) / GameConfig.playArea)*100);
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
		var midpoint:Vec2 = Vec2.get(platform.sprite.x._ + platform.sprite.getNaturalWidth() / 2, platform.sprite.y._ + platform.sprite.getNaturalHeight() / 2);
		var dimensions:Vec2 = Vec2.get(platform.sprite.getNaturalWidth(), platform.sprite.getNaturalHeight());
		var position:Vec2 = Vec2.get(platform.sprite.x._, platform.sprite.y._);
		var orientation:String = platform.sprite.getNaturalHeight() > platform.sprite.getNaturalWidth()?GameConfig.VERTICAL:GameConfig.HORIZONTAL;
		return { area:cast area, midpoint:cast midpoint, orientation: cast orientation, position: cast position, dimensions : cast dimensions }
	}
}