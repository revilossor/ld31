package urgame.scenes.play;
import flambe.Entity;

/**
 * ...
 * @author Oliver Ross
 */
class PlayScene
{
	public static function create(data:Map<String, Dynamic> = null, keys:Int = 0, haz:Int = 0):Entity {
		return new Entity().add(new PlayModel(data, keys, haz));
	}
}