package urgame.scenes.summary;
import flambe.Entity;

/**
 * ...
 * @author Oliver Ross
 */
class SummaryScene
{
	public static function create(data:Map<String, Dynamic>):Entity {
		return new Entity().add(new SummaryModel(data));
	}
}