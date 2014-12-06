package urgame.scenes.menu;
import flambe.animation.Ease;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.scene.SlideTransition;
import flambe.System;
import oli.OliGameContext;
import oli.util.OliG;
import urgame.scenes.play.PlayScene;

/**
 * ...
 * @author Oliver Ross
 */
class MenuModel extends Component
{
	private var _touchToPlay:ImageSprite;
	
	public function new() 
	{
		
	}
	override public function onAdded():Void {
		addGraphics();
		System.pointer.up.connect(function(e:PointerEvent):Void {
			var transition:SlideTransition = new SlideTransition(1, Ease.quadIn);
			OliGameContext.instance.director.unwindToScene(PlayScene.create(), transition.up());
		});
			
		
	}
	
	private function addGraphics():Void {
		owner.addChild(new Entity().add(new FillSprite(GameConfig.bgColour, OliG.width, OliG.height)));	// bg
		owner.addChild(new Entity()
			.add(_touchToPlay = new ImageSprite(OliGameContext.instance.assets.getTexture('menu/touch-to-play'))));
	}
	
}