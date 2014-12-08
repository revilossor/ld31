package urgame.scenes.play.comp;
import flambe.animation.Sine;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.math.Rectangle;
import nape.geom.Vec2;
import oli.OliGameContext;

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
		var sprite:ImageSprite = new ImageSprite(OliGameContext.instance.assets.getTexture('play/goal'));
		sprite.setXY(position.x, position.y-2);
		owner.add(sprite);
		rect = new Rectangle(position.x, position.y-2, 15, 17);
	}
	public function getMidpoint():Vec2 {
		return Vec2.get(position.x + rect.width, position.y + rect.height);
	}
}