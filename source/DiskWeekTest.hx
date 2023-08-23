import sys.FileSystem;
import flixel.text.FlxText;
using StringTools;
class DiskWeekTest extends MusicBeatState {
    var text:FlxText;
    override public function create() {
        text = new FlxText(60, 235, flixel.FlxG.width, "", 24);
        text.autoSize = false;
        text.alignment = CENTER;
        add(text);
        reloadDisk();
        super.create();
    }
    function reloadDisk()
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
                            text.text = "Cannot read disk \"" + shit[0] + '"';
                            return;
                        }
                    }
                }

                for (i in 1...5) {
                    trace('week $i exists is ${FileSystem.exists('cdreader/week$i.iso')}');
                }
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

            } else if ((folder.length == 1 && folder.contains('readme.txt')) || (folder.length == 0 && !folder.contains('readme.txt')))
            {
                text.text = "Insert a disk from assets/cds to cdreader/\nTo load a week";
            } else {
                text.text = "Disk overload\nOnly one disk can be inside the reader";
            }
        } catch(error:Dynamic){
            trace(error);
            text.text = 'An Error Occured While Checking For Disc\nError: "$error"';
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