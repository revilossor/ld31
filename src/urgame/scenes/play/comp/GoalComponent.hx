package urgame.scenes.play.comp;
import flambe.Component;
import flambe.display.FillSprite;

/**
 * ...
 * @author Oliver Ross
 */
class GoalComponent extends Component
{
	private var _xp:Float;
	private var _yp:Float;
	
	public function new(xp:Float, yp:Float) 
	{
		_xp = xp;
		_yp = yp;
	}
	override public function onAdded():Void {
		var sprite:FillSprite = new FillSprite(0x888888, 15, 15);
		sprite.setXY(_xp, _yp);
		owner.add(sprite);
	}
}