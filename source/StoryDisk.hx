import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import sys.FileSystem;
using StringTools;
class StoryDisk extends MusicBeatState {
    var discImage:FlxSprite;
    var textForDisc:FlxText;
    override public function create() {
        discImage = new FlxSprite(FlxG.width / 2 + 50);
        add(discImage);
        textForDisc = new FlxText(50, 0, FlxG.width / 2 - 50, "", 26, true);
        add(textForDisc);
        textForDisc.alignment = CENTER;
        textForDisc.screenCenter(Y);
        reloadDisk(true);
        super.create();
    }
    function reloadDisk(firstTime:Bool)
    {
        try {
            if (!FileSystem.exists('./cdreader')) FileSystem.createDirectory('./cdreader');
            var folder:Array<String> = FileSystem.readDirectory('./cdreader');
            var maxNumOfFiles = 1;
            if (folder.contains('readme.txt')) maxNumOfFiles = 2;
            if (folder.length == maxNumOfFiles) {
                for (i in 0...folder.length - 1)
                {
                    if (!folder[i].endsWith('iso'))
                    {
                        if (folder[i] != 'readme.txt') {
                            var shit = folder[i].split(".");
                            showErrorText("Cannot read disk \"" + shit[0] + '"');
                            return;
                        }
                    }
                }

                if (FileSystem.exists('cdreader/week1.iso'))
                {
                    showTextAlongDisk("Week 1 Inserted");
                    showDisc("Disc_1", firstTime);
                } else if (FileSystem.exists('cdreader/week2.iso'))
                {
                    showTextAlongDisk("Week 2 Inserted");
                    showDisc("Disc_2", firstTime);
                } else if (FileSystem.exists('cdreader/week3.iso'))
                {
                    showTextAlongDisk("Week 3 Inserted");
                    showDisc("Disc_3", firstTime);
                } else if (FileSystem.exists('cdreader/week4.iso'))
                {
                    showTextAlongDisk("Week 4 Inserted");
                    showDisc("Disc_4", firstTime);
                } else if (FileSystem.exists('cdreader/week5.iso'))
                {
                    showTextAlongDisk("Week 5 Inserted");
                    showDisc("Disc_5", firstTime);
                } else {
                    showTextAlongDisk("Unknown Disk Inserted");
                    showDisc("Disc_Unknown", firstTime);
                }
            } else if ((folder.length == 1 && folder.contains('readme.txt')) || (folder.length == 0 && !folder.contains('readme.txt')))
            {
                showTextAlongDisk('Insert a disk from "assets/cds" to "cdreader/"\nTo load a week');
                showDisc("Disc_Unknown", firstTime);
            } else {
                showTextAlongDisk("Disk overload\nOnly one disk can be inside the reader");
                showDisc("Disc_Unknown", firstTime);
            }
        } catch(error:Dynamic){
            showTextAlongDisk('An Error Occured While Checking For Disc\nError: "$error"');
        }
    }
    function showTextAlongDisk(text:String) {
        if (text != textForDisc.text) {
            var daVal = 50;
            FlxTween.tween(textForDisc, {x: textForDisc.x - daVal, alpha: 0}, 0.5, {ease: FlxEase.circInOut, onComplete: function(_) {
                textForDisc.text = text;
                textForDisc.screenCenter(Y);
                FlxTween.tween(textForDisc, {x: textForDisc.x + daVal, alpha: 1}, 0.5, {ease: FlxEase.circInOut});
            }});
        }
    }
    function showErrorText(error:String) {
        trace(error); //temp for now
    }
    var defaultDiscY:Float = 0;
    function showDisc(image:String, firstTime:Bool = false) {
        var toLoad = Paths.image('diskmenu/$image', 'preload');
        if (discImage.graphic != toLoad) {
            angleForDisc = 360 * 20;
            if (firstTime) {
                discImage.loadGraphic(Paths.image('diskmenu/$image', 'preload'));
                angleForDisc = 0;
                discImage.angle = 0;
                discImage.setGraphicSize(Std.int(FlxG.height / 1.8));
                discImage.updateHitbox();
                discImage.screenCenter(Y);
                defaultDiscY = discImage.y;
            } else {
                FlxTween.tween(discImage, {y: discImage.y + 600}, 0.5, {ease: FlxEase.circInOut, onComplete: function(_) {
                    discImage.loadGraphic(Paths.image('diskmenu/$image', 'preload'));
                    angleForDisc = 360 * 10;
                    FlxTween.tween(discImage, {y: defaultDiscY}, 0.5, {ease: FlxEase.circInOut, onStart: function(_){
                        discImage.angle = 0;
                        angleForDisc = 0;
                    }});
                }});
            }
        }
    }
    override function onFocus() {
        reloadDisk(false);
        super.onFocus();
    }
    var angleForDisc:Float = 0;
    override function update(elapsed:Float) {
        discImage.angle = FlxMath.lerp(angleForDisc, discImage.angle, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
        if (controls.BACK || wiimoteReadout.buttons.b) MusicBeatState.switchState(new MainMenuState());
        super.update(elapsed);
    }
}