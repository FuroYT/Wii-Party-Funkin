package test;

import Discord.DiscordClient;
import flixel.addons.ui.FlxUIButton;

class DiscordRPCIconTest extends MusicBeatState
{
    var icons:Array<String> = ["", "icon", "stupid-cursor", 'shop-tv', 'nightanova', 'perhaps', 'zombie-tag', 'strike', 'final-match', 'smash-battle', "new-super-funk", 'samurai-fight', 'rainbow-kart', "unknown", 'homebrew'];
    var curIcon:String = "";
    override function create() {
        var iconDropDown = new FlxUIDropDownMenuCustom(0, 10, FlxUIDropDownMenuCustom.makeStrIdLabelArray(icons, true), function(icon:String)
        {
            curIcon = icons[Std.parseInt(icon)];
        });
        add(iconDropDown);
        iconDropDown.screenCenter(X);
        var updateButton = new FlxUIButton(iconDropDown.x + iconDropDown.width + 20, iconDropDown.y, "Update", function() {
            DiscordClient.iconTest(curIcon);
        });
        add(updateButton);
        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.BACK) MusicBeatState.switchState(new MainMenuState());
        super.update(elapsed);
    }
}