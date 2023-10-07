package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
using StringTools;

class FreeplayState extends MusicBeatState
{
	var bottomText:FlxText;
	var bg:FlxSprite;
    var canPress:Bool = true;

	var menuItemsToAddBitch:Array<Dynamic> = [
		[180, 40, 'stupid-cursor'],
		[415, 40, 'shop-tv'],
		[650, 40, 'nightanova'],
		[885, 40, 'perhaps'],
		[180, 200, 'zombie-tag'],
		[415, 200, 'strike'],
		[650, 200, 'final-match'],
		[885, 200, 'smash-battle'],
		[180, 350, 'rainbow-kart'],
		[415, 350, 'unknown'],
		[650, 350, 'new-super-funk'],
		[885, 350, 'sakura-blossom']
	];

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var toolbar = new FlxSprite().loadGraphic(Paths.image('freeplay/toolbar'));
		toolbar.antialiasing = ClientPrefs.globalAntialiasing;
		toolbar.setGraphicSize(FlxG.width, FlxG.height);
		toolbar.updateHitbox();
		toolbar.screenCenter();
		add(toolbar);

		for (item in 0...menuItemsToAddBitch.length) {
			var sprite = new FlxSprite(menuItemsToAddBitch[item][0], menuItemsToAddBitch[item][1]).loadGraphic(Paths.image('freeplay/${menuItemsToAddBitch[item][2]}'));
			add(sprite);
			menuItemsToAddBitch[item].push(sprite);
		}

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		bottomText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 20);
		bottomText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		FlxG.sound.music.fadeOut(0.3, 0, function(_){
            FlxG.sound.playMusic(Paths.music("channels/freeplay/bgm"), 0.8);
			FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(Paths.music("channels/freeplay/bgm"), 0.8);};
        });
		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
	}

	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;

	function mouseShit():Bool
	{
		for (item in 0...menuItemsToAddBitch.length) {
			var spr = menuItemsToAddBitch[item][3];
			if (FlxG.mouse.overlaps(spr))
			{
				var shit = Std.string(menuItemsToAddBitch[item][2]).replace("-", " ");
				bottomText.text = 'Currently Selecting Song "${shit == "unknown" ? ")28;:)))??" : CoolUtil.toTitleCase(shit)}" - Click to play!';
				if (FlxG.mouse.justPressed) {
					startSong(menuItemsToAddBitch[item][2]);
				}
				return true;
			}
		}
		return false;
	}

	function startSong(songName:String) {
		persistentUpdate = false;
		PlayState.SONG = Song.loadFromJson(songName, songName);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
		canPress = false;
		if (FlxG.keys.pressed.SHIFT){
			LoadingState.loadAndSwitchState(new ChartingState());
		}else{
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (canPress)
		{
			if(!mouseShit())
				bottomText.text = "Hover a song with your mouse to select it!";
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (controls.BACK && canPress)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			canPress = false;
			FlxG.sound.music.fadeOut(0.3, 0, function(_){
				@:privateAccess
				FlxG.sound.playMusic(MainMenuState.wiiMainMenuMusic, 0);
				MusicBeatState.switchState(new MainMenuState());
				@:privateAccess
				FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(MainMenuState.wiiMainMenuMusic, 0.8);};
			});
		}
		super.update(elapsed);
	}
}