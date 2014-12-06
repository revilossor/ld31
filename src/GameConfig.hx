package ;
import flambe.display.Font;

/**
 * ...
 * @author Oliver Ross
 */
class GameConfig
{
	public static var bgColour:Int = 0x2c2c2c;
	
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
}