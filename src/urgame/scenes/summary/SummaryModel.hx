package urgame.scenes.summary;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.System;
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
	
	public function new(data:Map<String, Dynamic>) 
	{
		_data = data;
		_persistentData = fetchData();		
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
		
		trace('_levelPlatformsPlaced $_levelPlatformsPlaced \n_levelAreaUsed $_levelAreaUsed \n	_levelJumpsMade $_levelJumpsMade \n _levelTimeTaken $_levelTimeTaken \n _gamePlatformsPlaced $_gamePlatformsPlaced \n _gameJumpsMade $_gameJumpsMade \n _gameTimeTaken $_gameTimeTaken \n _allTimePlatformsPlaced $_allTimePlatformsPlaced \n _allTimeTimeTaken $_allTimeTimeTaken \n _allTimeLevelsComplete $_allTimeLevelsComplete');
	}
	override public function onAdded():Void {
		Viewport.instance.fadeIn(0x000000, 1);
		owner.addChild(new Entity().add(new FillSprite(GameConfig.bgColour, OliG.width, OliG.height)));	// bg
		initInteraction();
	}
	
	private function initInteraction():Void {
		System.pointer.up.connect(function(e:PointerEvent):Void {
			Viewport.instance.fadeOut(0x000000, 1, function():Void {
				updatePeristentData();
				OliGameContext.instance.director.unwindToScene(PlayScene.create(_data));
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