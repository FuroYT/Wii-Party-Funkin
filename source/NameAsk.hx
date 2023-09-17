import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;

class NameAsk extends MusicBeatState {
    var textBox:FlxUIInputText;
    var doneButton:FlxButton;
    var text:FlxText;

    override function create() {
        FlxG.mouse.visible = true;
        textBox = new FlxUIInputText(0, 0, Std.int(FlxG.width / 4), 'Username');
        add(textBox);
        textBox.screenCenter(XY);
        doneButton = new FlxButton(textBox.x, textBox.y + 50, 'Done', function()
        {
            if (textBox.text != null && textBox.text != '') {
                FlxG.save.data.usernameForCrash = textBox.text;
                ClientPrefs.saveSettings();
                FlxG.switchState(Type.createInstance(Main.initialState, []));
            }
        });
        add(doneButton);
        doneButton.screenCenter(X);
        text = new FlxText(0, 0, FlxG.width, 'What is your username?', 32);
        text.alignment = CENTER;
        text.bold = true;
        add(text);
        super.create();
    }
}