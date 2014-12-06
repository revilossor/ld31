package urgame.scenes;
import flambe.display.FillSprite;
import flambe.Entity;
import oli.util.OliG;

/**
 * ...
 * @author Oliver Ross
 */
class MenuScene
{
	public static function create():Entity {
		var scene:Entity = new Entity();
		scene.add(new FillSprite(0xff00ff, OliG.width, OliG.height));
		return scene;
	}
	
}