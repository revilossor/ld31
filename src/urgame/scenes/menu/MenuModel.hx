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
import oli.Viewport;
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
			OliGameContext.instance.assets.getSound('menu').play(0.3);
			Viewport.instance.fadeOut(0x000000, 1, function():Void {
				OliGameContext.instance.director.unwindToScene(PlayScene.create());
			});
		}).once();	
	}
	private function addGraphics():Void {
		owner.addChild(new Entity().add(new ImageSprite(OliGameContext.instance.assets.getTexture('menu/menu'))));	// bg
	}
	
}