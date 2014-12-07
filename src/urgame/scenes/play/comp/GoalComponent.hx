package urgame.scenes.play.comp;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.math.Rectangle;
import nape.geom.Vec2;

/**
 * ...
 * @author Oliver Ross
 */
class GoalComponent extends Component
{
	public var position:Vec2;
	public var rect:Rectangle;
	
	public function new(xp:Float, yp:Float) 
	{
		position = Vec2.get(xp, yp);
	}
	override public function onAdded():Void {
		var sprite:FillSprite = new FillSprite(0x888888, 15, 15);
		sprite.setXY(position.x, position.y);
		owner.add(sprite);
		rect = new Rectangle(position.x, position.y, 15, 15);
	}
}