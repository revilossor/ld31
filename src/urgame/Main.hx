package urgame;
import flambe.animation.Ease;
import flambe.scene.FadeTransition;
import oli.OliGame;
import oli.OliGameContext;
import urgame.scenes.menu.MenuScene;


class Main
{
	private static function main ()
	{
		var game:OliGame = new OliGame(360, 220);
		game.ready.connect(function():Void {
			OliGameContext.instance.director.unwindToScene(MenuScene.create(), new FadeTransition(1, Ease.linear));
		}).once();
	}
}
