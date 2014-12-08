package urgame.scenes.summary;
import flambe.animation.Ease;
import flambe.animation.Sine;
import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.PatternSprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.System;
import nape.geom.Vec2;
import oli.OliGameContext;
import oli.util.OliG;
import oli.Viewport;
import urgame.scenes.play.PlayScene;

/**
 * ...
 * @author Oliver Ross
 * 
 * // how many baddies to add - total area used / 10
	// where to put baddies - midpoints of biggest platforms
	// direction of baddies - orientation of placed at platforms
	// minimap - from data
		
	/*
	 * 
	 * 	 stats
	 * 		level
	 * 			platforms placed
	 * 			area used
	 * 			jumps made
	 * 			time taken
	 * 		game
	 * 			platforms placed
	 * 			jumps made
	 * 			time taken
	 * 		all time
	 * 			platforms placed
	 * 			time taken
	 * 			levels completed
	 * 			
*/ 
class SummaryModel extends Component
{
	private var _data:Map<String, Dynamic>;
	
	private var _persistentData:Dynamic;
	
	private var _levelPlatformsPlaced:Int;
	private var _levelAreaUsed:Int;
	private var _levelJumpsMade:Int;
	private var _levelTimeTaken:Int;
	
	private var _gamePlatformsPlaced:Int;
	private var _gameJumpsMade:Int;
	private var _gameTimeTaken:Int;
	
	private var _allTimePlatformsPlaced:Int;
	private var _allTimeTimeTaken:Int;
	private var _allTimeLevelsComplete:Int;
	
	private var _areaPanel:ImageSprite;
	private var _areaPanelTitle:ImageSprite;
	private var _mapPanel:ImageSprite;
	private var _mapPanelTitle:ImageSprite;
	private var _statPanel:ImageSprite;
	private var _statPanelTitle:ImageSprite;
	private var _titlePanel:ImageSprite;

	private var font:Font;
	
	private var _numKeys:Int = 0;
	private var _lastKeys:Int = 0;
	
	private var _numHaz:Int = 0;
	private var _lastHaz:Int = 0;
	
	private var _keySprites:Array<ImageSprite> = new Array<ImageSprite>();
	
	public function new(data:Map<String, Dynamic>, keys:Int, haz:Int) 		//TODO theres a bug with jumping nd turning, seems to be when viewport scle gets over a certain size
	{
		_data = data;
		_persistentData = fetchData();
		_lastKeys = keys;
		_lastHaz = haz;
		initData();
	}
	
	private function initData():Void {
		_levelPlatformsPlaced = Lambda.count(_data.get(GameConfig.PLATFORMS));
		_levelAreaUsed = _data.get(GameConfig.SCREEN_AREA);
		_levelJumpsMade = _data.get(GameConfig.JUMPS);
		_levelTimeTaken = _data.get(GameConfig.TIME_TAKEN);
		_gamePlatformsPlaced = _data.get(GameConfig.GAME_PLATFORMS_PLACED);
		_gameJumpsMade = _data.get(GameConfig.GAME_JUMPS);
		_gameTimeTaken = _data.get(GameConfig.GAME_TIME_TAKEN);
		_allTimePlatformsPlaced = _persistentData.platforms + _levelPlatformsPlaced;
		_allTimeTimeTaken = _persistentData.time + _levelTimeTaken;
		_allTimeLevelsComplete = _persistentData.levels + 1;	
	}
	
	private function initGfx():Void {
		var a:AssetPack = OliGameContext.instance.assets;
		_areaPanel = new ImageSprite(a.getTexture('summary/area-panel'));					//5, 190
		_areaPanelTitle = new ImageSprite(a.getTexture('summary/area-panel-title'));		//9, 177
		_mapPanel = new ImageSprite(a.getTexture('summary/map-panel'));						//17, 53
		_mapPanelTitle = new ImageSprite(a.getTexture('summary/map-panel-title'));			//146, 41
		_statPanel = new ImageSprite(a.getTexture('summary/statistics-panel'));				//200, 35
		_statPanelTitle = new ImageSprite(a.getTexture('summary/statistics-panel-title'));	//204, 22
		_titlePanel = new ImageSprite(a.getTexture('summary/title-panel'));					//4, 4
		
		_areaPanel.setXY(5, 190);
		_areaPanelTitle.setXY(284, 177);
		_areaPanel.alpha._ = 0;
		_areaPanel.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		_areaPanelTitle.x.animateTo(9, GameConfig.summaryInitDuration, Ease.quadIn);
		_areaPanelTitle.alpha._ = 0;
		_areaPanelTitle.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		
		_mapPanel.setXY(17, 53);
		_mapPanelTitle.setXY(21, 41);
		_mapPanel.alpha._ = 0;
		_mapPanel.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		_mapPanelTitle.x.animateTo(146, GameConfig.summaryInitDuration, Ease.quadIn);
		_mapPanelTitle.alpha._ = 0;
		_mapPanelTitle.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		
		_statPanel.setXY(200, 35);
		_statPanel.alpha._ = 0;
		_statPanel.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		_statPanelTitle.setXY(279, 22);
		_statPanelTitle.x.animateTo(204, GameConfig.summaryInitDuration, Ease.quadIn);
		_statPanelTitle.alpha._ = 0;
		_statPanelTitle.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		
		_titlePanel.setXY(4, 4);
		_titlePanel.alpha._ = 0;
		_titlePanel.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.linear);
		
		owner.addChild(new Entity().add(_areaPanel));
		owner.addChild(new Entity().add(_areaPanelTitle));
		owner.addChild(new Entity().add(_mapPanel));
		owner.addChild(new Entity().add(_mapPanelTitle));
		owner.addChild(new Entity().add(_statPanel));
		owner.addChild(new Entity().add(_statPanelTitle));
		owner.addChild(new Entity().add(_titlePanel));
		
		//font = new Font(a, 'nokia_6_red');
		
		font = new Font(a, 'fixedsys_6');
		initResults();
	}
	private function initResults():Void {
		var levelPlatformsPlaced:TextSprite = new TextSprite(font, ''+_levelPlatformsPlaced);
		var levelAreaUsed:TextSprite = new TextSprite(font, ''+_levelAreaUsed);
		var levelJumpsMade:TextSprite = new TextSprite(font, ''+_levelJumpsMade);
		var levelTimeTaken:TextSprite = new TextSprite(font, ''+(Math.round(_levelTimeTaken/60)));
	
		var gamePlatformsPlaced:TextSprite = new TextSprite(font, ''+_gamePlatformsPlaced);
		var gameJumpsMade:TextSprite = new TextSprite(font, ''+_gameJumpsMade);
		var gameTimeTaken:TextSprite = new TextSprite(font, ''+(Math.round(_gameTimeTaken/60)));
	
		var allTimePlatformsPlaced:TextSprite = new TextSprite(font, ''+_allTimePlatformsPlaced);
		var allTimeTimeTaken:TextSprite = new TextSprite(font, ''+(Math.round(_allTimeTimeTaken/60)));
		var allTimeLevelsComplete:TextSprite = new TextSprite(font, ''+_allTimeLevelsComplete);
		
		levelPlatformsPlaced.setXY(290, 46);
		levelAreaUsed.setXY(290, 56);
		levelJumpsMade.setXY(290, 66);
		levelTimeTaken.setXY(290, 76);
		gamePlatformsPlaced.setXY(290, 96);
		gameJumpsMade.setXY(290, 106);
		gameTimeTaken.setXY(290, 116);
		allTimePlatformsPlaced.setXY(290, 136);
		allTimeTimeTaken.setXY(290, 146);
		allTimeLevelsComplete.setXY(290, 156);
		
		owner.addChild(new Entity().add(levelPlatformsPlaced));
		owner.addChild(new Entity().add(levelJumpsMade));
		owner.addChild(new Entity().add(levelTimeTaken));
		owner.addChild(new Entity().add(levelAreaUsed));
		owner.addChild(new Entity().add(gamePlatformsPlaced));
		owner.addChild(new Entity().add(gameJumpsMade));
		owner.addChild(new Entity().add(gameTimeTaken));
		owner.addChild(new Entity().add(allTimePlatformsPlaced));
		owner.addChild(new Entity().add(allTimeTimeTaken));
		owner.addChild(new Entity().add(allTimeLevelsComplete));
		
		initPlatforms();
	}
	
	private function initPlatforms():Void {
		var placed:Array<Dynamic> = _data.get(GameConfig.PLATFORMS);
		
		var origin:Vec2 = Vec2.get(21, 57);
		var scale:Vec2 = Vec2.get(156 / OliG.width, 92 / OliG.height);
		
		for (platform in placed) {
			var pos:Vec2 = cast platform.position;
			var dim:Vec2 = cast platform.dimensions;
			//trace('platform at ' + pos.x);
			var pl:FillSprite = new FillSprite(0x006cd6, dim.x * scale.x, dim.y * scale.y);
			pl.setXY(origin.x + (pos.x * scale.x), origin.y + (pos.y * scale.y));
			owner.addChild(new Entity().add(pl)); 
		}
		initBar();
	}
	
	private function initBar():Void {	//339, 12
		var wid:Float = 3.39 * _levelAreaUsed;
		trace('bar should be ' + _levelAreaUsed + '% full , which is width $wid');
		var sp:PatternSprite = new PatternSprite(OliGameContext.instance.assets.getTexture('summary/bar-fill'), wid, 12);
		sp.setXY(11, 198);
		owner.addChild(new Entity().add(sp));
		
		initKeys();
	}
	
	private function initKeys():Void {
		addKeySprite(41, 201);
		addKeySprite(74, 201);
		addKeySprite(109, 201);
		addKeySprite(142, 201);
		addKeySprite(176, 201);
		addKeySprite(211, 201);
		addKeySprite(245, 201);
		addKeySprite(279, 201);
		addKeySprite(313, 201);
		_numKeys = Math.floor(_levelAreaUsed / GameConfig.keysMod);
		trace('place $_numKeys on next level');
		var c:Int = _numKeys;
		for (key in _keySprites) {
			if (c-- > 0) {
				key.alpha.animateTo(1, 9 - c, Ease.linear);
			}
		}
		
		initHazards();
	}
	
	private function initHazards():Void {
		_numHaz = _levelJumpsMade > 7?1:0;
		trace('add $_numHaz hazards');
		
		var bat:ImageSprite = new ImageSprite(OliGameContext.instance.assets.getTexture('play/bat'));
		bat.setXY(330, 71);
		bat.alpha._ = 0;
		bat.centerAnchor();
		bat.scaleX.behavior = new Sine(1, 1.3);
		bat.scaleY.behavior = new Sine(1, 1.3);
		owner.addChild(new Entity().add(bat));
		if (_numHaz > 0) {
			bat.alpha.animateTo(1, GameConfig.summaryInitDuration, Ease.bounceIn);
		}
	}
	
	private function addKeySprite(xp:Float, yp:Float):Void {
		var key:ImageSprite = new ImageSprite(OliGameContext.instance.assets.getTexture('play/key'));
		key.setXY(xp, yp);
		key.alpha._ = 0;
		_keySprites.push(key);
		owner.addChild(new Entity().add(key));
	}
	override public function onAdded():Void {
		Viewport.instance.fadeIn(0x000000, 1);
		owner.addChild(new Entity().add(new ImageSprite(OliGameContext.instance.assets.getTexture('play/bg'))));	// bg
		
		initInteraction();
		initGfx();
	}
	
	private function initInteraction():Void {
		System.pointer.up.connect(function(e:PointerEvent):Void {
			OliGameContext.instance.assets.getSound('menu').play(0.3);
			Viewport.instance.fadeOut(0x000000, 1, function():Void {
				updatePeristentData();
				OliGameContext.instance.director.unwindToScene(PlayScene.create(_data, _numKeys + _lastKeys, _numHaz + _lastHaz));
			});
		}).once();
	}
	
	private function updatePeristentData():Void {
		storeData( { platforms:cast _allTimePlatformsPlaced, time : cast _allTimeTimeTaken, levels : cast _allTimeLevelsComplete } );
	}
	
	private function storeData(data:Dynamic):Void {
		System.storage.set(GameConfig.PERSISTENT_DATA_KEY, data); 
	}
	private function fetchData():Dynamic {
		return System.storage.get(GameConfig.PERSISTENT_DATA_KEY, { platforms:cast 0, time : cast 0, levels : cast 1 } );
	}
}