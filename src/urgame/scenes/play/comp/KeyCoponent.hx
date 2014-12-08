package urgame.scenes.play.comp;
import flambe.animation.Sine;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.math.Rectangle;
import nape.geom.Vec2;
import oli.OliGameContext;

/**
 * ...
 * @author Oliver Ross
 */
class KeyCoponent extends Component
{
	public var position:Vec2;
	public var rect:Rectangle;
	
	private var sprite:ImageSprite;
	
	public function new(xp:Float, yp:Float) 
	{
		position = Vec2.get(xp, yp);
	}
	override public function onAdded():Void {
		sprite = new ImageSprite(OliGameContext.instance.assets.getTexture('play/key'));
		sprite.setXY(position.x, position.y);
		owner.addChild(new Entity().add(sprite));
		rect = new Rectangle(position.x, position.y, 9, 5);
		sprite.centerAnchor();
		var offset:Float = Math.random();
		sprite.scaleX.behavior = new Sine(1, 1.3, 1, 0, offset);
		sprite.scaleY.behavior = new Sine(1, 1.3, 1, 0, offset);
	}
	public function getMidpoint():Vec2 {
		return Vec2.get(position.x + sprite.getNaturalWidth(), position.y + sprite.getNaturalHeight());
	}
	public function remove():Void {
		sprite.dispose();
		
		dispose();
	}
}