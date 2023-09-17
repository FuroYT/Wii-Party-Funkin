import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.FlxUIInputText;

class HomebrewMenu extends MusicBeatState {
    var textBox:FlxUIInputText;
    var canPress:Bool = true;
    //"code" => "song"
    var redirections:Map<String, String> = [
        "red letter" => "letter-bomb",
        "fucking cursor" => "wad",
        "mayro nubre 69" => "supra mayro krat",
        "im dead man" => "monosporting"
	];

    override function create() {
        var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("homebrew/bg"));
		bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        add(bg);
        bg.screenCenter(XY);
        FlxG.mouse.visible = true;
        textBox = new FlxUIInputText(0, 0, Std.int(FlxG.width / 4), '');
        add(textBox);
        textBox.screenCenter(XY);
        FlxG.sound.music.fadeOut(0.3, 0, function(_){
            FlxG.sound.playMusic(Paths.music("channels/homebrew/bgm"), 0.8);
			FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(Paths.music("channels/homebrew/bgm"), 0.8);};
        });
        super.create();
    }

    function checkAndStartSong(map:Map<String, String>, get:String) {
        if (map.exists(get)) {
            startSong(map.get(get));
            canPress = false;
            return true;
        } else {
            return false;
        }
    }

    function startSong(songName:String) {
		persistentUpdate = false;
		PlayState.SONG = Song.loadFromJson(songName, songName);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}

    override function update(elapsed:Float)
    {
        if ((textBox.text != "" && textBox.text != null) && controls.ACCEPT)
        {
            if (FlxG.keys.pressed.SPACE) return;
            if (!checkAndStartSong(redirections, textBox.text.toLowerCase()))
            {
                FlxG.camera.shake(0.01, 0.05, null, true, X);
            }
        }
        if (controls.BACK && canPress)
        {
            if (FlxG.keys.pressed.BACKSPACE) return;
            if (textBox.hasFocus) {
                textBox.hasFocus = false;
            } else {
                canPress = false;
                FlxG.sound.music.fadeOut(0.3, 0, function(_){
                    @:privateAccess
                    FlxG.sound.playMusic(MainMenuState.wiiMainMenuMusic, 0);
                    MusicBeatState.switchState(new MainMenuState());
                    @:privateAccess
			        FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(MainMenuState.wiiMainMenuMusic, 0.8);};
                });
            }
        }
        super.update(elapsed);
    }
}