import flixel.FlxG;
import flash.display.BitmapData;

@:bitmap("assets/exclude/system/mouse.png")
class NormalCursor extends BitmapData {}
@:bitmap("assets/exclude/system/mouse-homebrew.png")
class HomebrewCursor extends BitmapData {}

class MouseCursors {
    public static function loadCursor(cursorToLoad:String) {
        var cursor:BitmapData;
        switch (cursorToLoad.toLowerCase())
        {
            case 'normal' | 'wii' | 'basic':
                cursor = new NormalCursor(0, 0);
            case 'fail0verflow' | 'homebrew' | 'hack':
                cursor = new HomebrewCursor(0, 0);
            default:
                cursor = new NormalCursor(0, 0);
        }
        trace('loaded cursor $cursorToLoad');
        FlxG.mouse.load(cursor);
    }
}