package ;
import flambe.display.Font;
import nape.geom.Vec2;
import oli.util.OliG;

/**
 * ...
 * @author Oliver Ross
 */
class GameConfig
{
	public static var bgColour:Int = 0x2c2c2c;
	
	public static var playArea:Float = 79200;
	
	public static var SCREEN_AREA:String = 'screen_area';
	public static var TOTAL_GAME_AREA:String = 'total_game_area';
	public static var PLATFORMS:String = 'platforms';
	
	public static var PLATFORMS_PLACED:String = 'platforms_placed';
	public static var LEVELS:String = 'levels';
	public static var TIME_TAKEN:String = 'time_taken';
	public static var GAME_TIME_TAKEN:String = 'game_time_taken';
	public static var JUMPS:String = 'jumps';
	public static var GAME_JUMPS:String = 'game_jumps';
	public static var GAME_PLATFORMS_PLACED:String = 'game_platforms_placed';
	
	public static var VERTICAL:String = 'vertical';
	public static var HORIZONTAL:String = 'horizontal';
	
	public static var PERSISTENT_DATA_KEY:String = 'ld31-onescreen-revilossor-data';
	
	public static var borderWidth:Float = 4;
	public static var borderColour:Int = 0xff00ff;
	
	public static var playerWidth:Float = 10; 
	public static var playerHeight:Float = 14; 
	public static var playerColour:Int = 0x00ff00;
	public static var playerSpeed:Float = 50;
	public static var playerTapRadius:Float = 20;
	public static var playerJumpInitial:Float = 15;
	public static var playerJumpHold:Float = 2.75;
	public static var playerJumpDuration:Int = 20;
	
	public static var tempRectColour:Int = 0xffffff;
	public static var tempRectErrorColour:Int = 0xff0000;
	public static var tempRectAlpha:Float = 0.5;
	
	public static var platformColour:Int = 0xff00ff;
	public static var minimumPlatformSize:Float = 16;
	
	public static var goalPlatformColour:Int = 0x888888;
	public static var goalX:Float = 158;
	public static var goalY:Float = 20;
}