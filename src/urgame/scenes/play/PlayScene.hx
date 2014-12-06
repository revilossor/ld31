package urgame.scenes.play;
import flambe.Entity;

/**
 * ...
 * @author Oliver Ross
 */
class PlayScene
{
	public static function create():Entity {
		return new Entity().add(new PlayModel());
	}
}