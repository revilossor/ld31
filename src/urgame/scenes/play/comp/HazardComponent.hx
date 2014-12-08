package urgame.scenes.play.comp;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Rectangle;
import flambe.swf.Flipbook;
import flambe.swf.Library;
import flambe.swf.MovieSprite;
import nape.geom.Vec2;
import oli.OliGameContext;
import oli.util.OliG;

/**
 * ...
 * @author Oliver Ross	TODO - can click on to stop
 */
class HazardComponent extends Component
{
	private var _position:Vec2;
	private var _velocity:Vec2;
	private var sprite:MovieSprite;
	
	private var _stopped:Bool = false;
	
	public function getRect():Rectangle {
		return new Rectangle(sprite.x._ + 2, sprite.y._ + 2, 6, 6);
	}
	
	public function new(xp:Float, yp:Float) 
	{
		_position = Vec2.get(xp, yp);
		_velocity = new Vec2(-40 + Math.random() * 80, -30 + Math.random() * 60);
	}
	override public function onAdded():Void {
		var lib:Library = Library.fromFlipbooks([
			new Flipbook('fly', OliGameContext.instance.assets.getTexture('play/batsheet').split(2)).setDuration(0.3)
		]);
		sprite = lib.createMovie('fly');
		sprite.setXY(_position.x, _position.y);
		owner.addChild(new Entity().add(sprite));
		sprite.pointerDown.connect(function(e:PointerEvent):Void {
			stop();
		});
		sprite.pointerOut.connect(function(e:PointerEvent):Void {
			go();
		});
	}
	override public function onUpdate(dt:Float):Void {
		if(!_stopped){
			sprite.x._ += _velocity.x * dt;
			sprite.y._ += _velocity.y * dt;
			var rect = getRect();
			if (rect.left < 4 || rect.right > OliG.width - 4) {
				_velocity.x *= -1;
			}
			if (rect.top < 4 || rect.bottom > OliG.height - 4) {
				_velocity.y *= -1;
			}
		}
	}
	public function stop():Void {
		_stopped = true;
	}
	public function go():Void {
		_stopped = false;
	}
	
}