package urgame.scenes;
import flambe.animation.Ease;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.System;
import oli.OliGameContext;
import oli.Viewport;
import urgame.scenes.menu.MenuScene;

/**
 * ...
 * @author Oliver Ross
 */
class DedScene
{
	public static function create():Entity {
		var scene:Entity = new Entity();
		
		Viewport.instance.fadeIn(0x000000, 0.5);
		
		scene.addChild(new Entity().add(new ImageSprite(OliGameContext.instance.assets.getTexture('play/bg'))));
		var bite:ImageSprite = new ImageSprite(OliGameContext.instance.assets.getTexture('bite'));
		bite.setXY( -336, 34);
		bite.x.animateTo(15, 1, Ease.bounceOut);
		scene.addChild(new Entity().add(bite));
		
		var faint:ImageSprite = new ImageSprite(OliGameContext.instance.assets.getTexture('you-fainted'));
		faint.setXY(370, 132);
		var script:Script = new Script();
		script.run(new Sequence([
			new Delay(0.5), 
			new CallFunction(function() {
				faint.x.animateTo(40, 1, Ease.bounceOut);
			}),
			new Delay(2), 
			new CallFunction(function() {
				Viewport.instance.fadeOut(0x000000, 1, function() {
					OliGameContext.instance.director.unwindToScene(MenuScene.create());
				});
			})
		]));
		scene.addChild(new Entity().add(script).add(faint));
		return scene;
	}
	
}