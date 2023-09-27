import flixel.FlxCamera;
import flixel.FlxSprite;

class HealthBar {
    var bgBar:FlxSprite;
    public function new(){bgBar = new FlxSprite(0, (ClientPrefs.downScroll ? -29.5 : 487.5));}
    public function createBar() {
        @:privateAccess
        PlayState.instance.remove(PlayState.instance.healthBarBG);
        PlayState.instance.remove(PlayState.instance.healthBar);
        bgBar.loadGraphic(Paths.image('healthbarOV', 'shared'));
        PlayState.instance.add(bgBar);
        if (ClientPrefs.downScroll) bgBar.flipY = true;
        bgBar.scale.set(0.9, 0.9);
        bgBar.updateHitbox();
        @:privateAccess
        PlayState.instance.add(PlayState.instance.healthBarBG);
        PlayState.instance.add(PlayState.instance.healthBar);
        bgBar.camera = PlayState.instance.camHUD;
        bgBar.screenCenter(X);
    }
}