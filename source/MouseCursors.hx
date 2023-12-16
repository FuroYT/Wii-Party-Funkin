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
            case 'normal' | 'wii':
                cursor = new NormalCursor(0, 0);
            case 'homebrew':
                cursor = new HomebrewCursor(0, 0);
            default:
                cursor = new NormalCursor(0, 0);
        }
        trace('loaded cursor $cursorToLoad');
        FlxG.mouse.load(cursor);
    }
}