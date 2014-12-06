package urgame.scenes.menu ;
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
		return new Entity().add(new MenuModel());
	}
	
}