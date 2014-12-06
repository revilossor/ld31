package urgame.scenes.play.comp;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import oli.nape.SpaceComponent;

/**
 * ...
 * @author Oliver Ross
 */
class RectBody extends Component
{
	private var _xp:Float;
	private var _yp:Float;
	private var _width:Float;
	private var _height:Float;
	private var _colour:Int;
	
	public var body:Body;
	public var sprite:FillSprite;
	
	public function new(xp:Float, yp:Float, width:Float, height:Float, colour:Int) 
	{
		_colour = colour;
		_height = height;
		_width = width;
		_yp = yp;
		_xp = xp;
	}
	override public function onAdded():Void {	
		body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(_xp, _yp, _width, _height)));
		PlayModel.space.addBody(body);
		
		sprite = new FillSprite(_colour, _width, _height);
		sprite.setXY(_xp, _yp);
		owner.addChild(new Entity().add(sprite));
	}
	
	
}