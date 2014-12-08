package urgame.scenes.summary;
import flambe.Entity;

/**
 * ...
 * @author Oliver Ross
 */
class SummaryScene
{
	public static function create(data:Map<String, Dynamic>, keys:Int = 0, haz = 0):Entity {
		return new Entity().add(new SummaryModel(data, keys, haz));
	}
}