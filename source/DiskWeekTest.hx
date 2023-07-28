import openfl.filesystem.File;
import sys.FileSystem;
import flixel.addons.ui.FlxUIText;
using StringTools;
class DiskWeekTest extends MusicBeatState {
    var text:FlxUIText;
    var canCheck = false;
    override public function create() {
        text = new FlxUIText(60, 235, flixel.FlxG.width, "", 24);
        text.autoSize = false;
        text.alignment = CENTER;
        add(text);
        reloadDisk();
        super.create();
    }
    function reloadDisk()
    {
        var tempFolder:File = File.documentsDirectory;
        trace(tempFolder);
        if (!FileSystem.exists('./cdreader')) FileSystem.createDirectory('./cdreader');
        var folder:Array<String> = FileSystem.readDirectory('./cdreader');
        var maxNumOfFiles = 1;
        if (folder.contains('readme.txt')) maxNumOfFiles = 2;
        if (folder.length == maxNumOfFiles) {
            for (i in 0...folder.length)
            {
                if (folder[i] == 'readme.txt') return;
                if (!folder[i].endsWith('iso'))
                {
                    var shit = folder[i].split(".");
                    text.text = "Cannot read disk \"" + shit[0] + '"';
                    return;
                } else {
                    canCheck == true;
                }
            }

            if (canCheck) {
                if (FileSystem.exists('cdreader/week1.iso'))
                {
                    text.text = "Week 1 Inserted";
                } else if (FileSystem.exists('cdreader/week2.iso'))
                {
                    text.text = "Week 2 Inserted";
                } else if (FileSystem.exists('cdreader/week3.iso'))
                {
                    text.text = "Week 3 Inserted";
                } else if (FileSystem.exists('cdreader/week4.iso'))
                {
                    text.text = "Week 4 Inserted";
                } else if (FileSystem.exists('cdreader/week5.iso'))
                {
                    text.text = "Week 5 Inserted";
                } else {
                    text.text = "Unknown Disk Inserted";
                }
            }
        } else if ((folder.length == 1 && folder.contains('readme.txt')) || (folder.length == 0 && !folder.contains('readme.txt')))
        {
            text.text = "Insert a disk from assets/cds to cdreader/\nTo load a week";
        } else {
            text.text = "Disk overload\nOnly one disk can be inside the reader";
        }
        text.screenCenter(XY);
    }
    override function onFocus() {
        reloadDisk();
        super.onFocus();
    }
    override function update(elapsed:Float) {
        if (controls.BACK || wiimoteReadout.buttons.b) MusicBeatState.switchState(new MainMenuState());
        super.update(elapsed);
    }
}