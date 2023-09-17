import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import sys.FileSystem;
import flixel.util.FlxColor;
using StringTools;
class StoryDisk extends MusicBeatState {
    var bg:FlxSprite;
    var discImage:FlxSprite;
    var textForDisc:FlxText;
    var textForError:FlxText;
    var discValid:Bool = false;
    var curWeek:Int = -1;
    var redirections:Map<Int, Array<String>> = [
        1 => ["stupid-cursor", "shop-tv"],
        2 => ["nightanova", "perhaps", "zombie-tag"],
        3 => ["strike", "final-match", "smash-battle"],
        4 => ["new-super-funk", "sakura-blossom"],
        5 => ["rainbow-kart", "unknown"]
	];
    override public function create() {
        bg = new FlxSprite(0, 0).loadGraphic(Paths.image("diskmenu/bg", "preload"));
        bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);
        discImage = new FlxSprite(FlxG.width / 2 + 50);
        add(discImage);
        textForDisc = new FlxText(50, 0, FlxG.width / 2 - 50, "", 26, true);
        add(textForDisc);
        textForDisc.alignment = CENTER;
        textForDisc.screenCenter(Y);
        textForDisc.setFormat(null, textForDisc.size, FlxColor.BLACK);
        textForError = new FlxText(0, 0, FlxG.width, "", 26, true);
        add(textForError);
        textForError.alignment = CENTER;
        textForError.screenCenter(Y);
        textForError.setFormat(null, textForError.size, FlxColor.BLACK);
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

                for (i in 0...6) {
                    if (FileSystem.exists('cdreader/week${i}.iso'))
                    {
                        showTextAlongDisk('Week ${i} Inserted!\n\nPress ENTER to play!');
                        showDisc('Disc_${i}', firstTime);
                        curWeek = i;
                        discValid = true;
                        break;
                    } else {
                        discValid = false;
                    }
                }
                if (!discValid) {
                    showTextAlongDisk("Unknown Disk Inserted");
                    showDisc("Disc_Unknown", firstTime);
                    curWeek = -1;
                }
            } else if ((folder.length == 1 && folder.contains('readme.txt')) || (folder.length == 0 && !folder.contains('readme.txt')))
            {
                showTextAlongDisk('Insert a disk from "assets/cds" to "cdreader/"\nTo load a week');
                showDisc("Disc_Unknown", firstTime);
                curWeek = -1;
                discValid = false;
            } else {
                showTextAlongDisk("Disk overload\nOnly one disk can be inside the reader");
                showDisc("Disc_Unknown", firstTime);
                curWeek = -1;
                discValid = false;
            }
        } catch(error:Dynamic){
            showErrorText('An Error Occured While Checking For Disc\nError: "$error"');
            curWeek = -1;
            discValid = false;
        }
    }
    function showTextAlongDisk(text:String) {
        FlxTween.tween(discImage, {alpha: 1}, 0.5, {ease: FlxEase.circInOut});
        FlxTween.tween(textForError, {y: textForError.y - 40, alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        if (text != textForDisc.text) {
            var daVal = 50;
            FlxTween.tween(textForDisc, {x: textForDisc.x - daVal, alpha: 0}, 0.5, {ease: FlxEase.circInOut, onComplete: function(_) {
                textForDisc.text = text;
                textForDisc.screenCenter(Y);
                FlxTween.tween(textForDisc, {x: textForDisc.x + daVal, alpha: 1}, 0.5, {ease: FlxEase.circInOut});
            }});
        }
    }
    var defaultErrorY:Float = 0;
    function showErrorText(error:String) {
        FlxTween.tween(discImage, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        FlxTween.tween(textForDisc, {alpha: 0}, 0.5, {ease: FlxEase.circInOut, onComplete: function(_) {
            textForError.text = error;
            textForError.screenCenter(XY);
            defaultErrorY = textForError.y;
            textForDisc.text = "";
            if (defaultErrorY != textForError.y) {
                textForError.y -= 40;
                FlxTween.tween(textForError, {y: textForError.y + 40, alpha: 1}, 0.5, {ease: FlxEase.circInOut});
            }
        }});
        discImage.setGraphicSize(Std.int(FlxG.height / 1.8));
        discImage.updateHitbox();
        discImage.screenCenter(Y);
    }
    var defaultDiscY:Float = 0;
    function showDisc(image:String, firstTime:Bool = false) {
        FlxTween.tween(discImage, {alpha: 1}, 0.5, {ease: FlxEase.circInOut});
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
    function selectWeek(weekNum:Int) {
         trace('Selected Week $weekNum');
        var songs = redirections.get(weekNum);
        PlayState.storyPlaylist = songs;
        PlayState.isStoryMode = true;
        PlayState.storyWeek = weekNum;
        PlayState.SONG = Song.loadFromJson(songs[0], songs[0]);
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState(), true);
    }
    var angleForDisc:Float = 0;
    override function update(elapsed:Float) {
        discImage.angle = FlxMath.lerp(angleForDisc, discImage.angle, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
        if (controls.BACK || wiimoteReadout.buttons.b) MusicBeatState.switchState(new MainMenuState());
        if (FlxG.keys.justPressed.ENTER && curWeek != -1) selectWeek(curWeek);
        super.update(elapsed);
    }
}