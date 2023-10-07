import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

class NewsState extends MusicBeatState
{
    var textToDisplay:String = "Currently no news have been posted, for further news check @WiiPartyFunkinW on Twitter or wait for the next update,\n\nThank You.";
    var text:FlxText;
    var bg:FlxSprite;

    override function create() {
        bg = new FlxSprite(0, 0).loadGraphic(Paths.image("news/bg", "preload"));
        bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);
        text = new FlxText(0, 0, FlxG.width, textToDisplay, 26);
        text.screenCenter(XY);
        text.y -= 40;
        text.alpha = 0;
        text.setFormat(null, text.size, flixel.util.FlxColor.BLACK, CENTER);
        new FlxTimer().start(0.5, function(_){
            flixel.tweens.FlxTween.tween(text, {y: text.y + 40, alpha: 1}, 0.5, {ease: flixel.tweens.FlxEase.circInOut});
        });
        add(text);
        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.BACK || wiimoteReadout.buttons.b)
        {
            flixel.tweens.FlxTween.tween(text, {y: text.y + 40, alpha: 0}, 0.5, {ease: flixel.tweens.FlxEase.circInOut, onComplete: function(_){
                MusicBeatState.switchState(new MainMenuState());
            }});
        }
        super.update(elapsed);
    }
}

class NewsItem {}
typedef NewsData = {
    var title:String;
    var desc:String;
    var version:String;
    var date:String;
}