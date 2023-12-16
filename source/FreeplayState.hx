package;

import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
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

	var curSelected(default, set):Int;
	var curSong:String;
	var curDisplay:String;

	function mouseShit():Bool
	{
		for (item in 0...menuItemsToAddBitch.length) {
			var spr = menuItemsToAddBitch[item][3];
			if (FlxG.mouse.overlaps(spr))
			{
				var leText:String = "Press {RESET1} to reset your highscore.";
				leText = StringTools.replace(leText, "{RESET1}", ClientPrefs.keyBinds.get("reset")[0].toString());
				if (ClientPrefs.keyBinds.get("reset")[0] != FlxKey.NONE && ClientPrefs.keyBinds.get("reset")[1] != FlxKey.NONE)
				{
					leText = "Press {RESET1} or {RESET2} to reset your highscore.";
					leText = StringTools.replace(leText, "{RESET1}", ClientPrefs.keyBinds.get("reset")[0].toString());
					leText = StringTools.replace(leText, "{RESET2}", ClientPrefs.keyBinds.get("reset")[1].toString());
				}
				if (ClientPrefs.keyBinds.get("reset")[0] == FlxKey.NONE && ClientPrefs.keyBinds.get("reset")[1] != FlxKey.NONE)
				{
					leText = "Press {RESET1} to reset your highscore.";
					leText = StringTools.replace(leText, "{RESET1}", ClientPrefs.keyBinds.get("reset")[1].toString());
				}
				var shit = Std.string(menuItemsToAddBitch[item][2]).replace("-", " ");
				curDisplay = shit == "unknown" ? ")28;:)))??" : CoolUtil.toTitleCase(shit);
				curSong = menuItemsToAddBitch[item][2];
				bottomText.text = 'Song: $curDisplay - Click to play! | High score: ${Highscore.getScore(shit)} (${Highscore.floorDecimal(Highscore.getRating(shit) * 100, 2) }%) | $leText';
				if (FlxG.mouse.justPressed) {
					startSong(menuItemsToAddBitch[item][2]);
				}
				if (curSelected != spr.ID) curSelected = spr.ID;
				return true;
			}
		}
		return false;
	}

	function startSong(songName:String) {
		persistentUpdate = false;
		PlayState.SONG = Song.loadFromJson(songName, songName);
		PlayState.isStoryMode = false;
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
			if(!mouseShit()) {
				bottomText.text = "Hover a song with your mouse to select it!";
				curSelected = -1;
				curSong = "";
			}
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		for (item in 0...menuItemsToAddBitch.length)
		{
			var spr:FlxSprite = menuItemsToAddBitch[item][3];
			var size = curSelected == spr.ID ? 1.1 : 1;
			spr.scale.x = FlxMath.lerp(size, spr.scale.x, CoolUtil.boundTo(1 - (FlxG.elapsed * 3.125), 0, 1));
			spr.scale.y = FlxMath.lerp(size, spr.scale.y, CoolUtil.boundTo(1 - (FlxG.elapsed * 3.125), 0, 1));
		}

		if ((controls.BACK || wiimoteReadout.buttons.b) && canPress)
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
		} else if (controls.RESET && canPress)
		{
			if (curSong == "") return;
			canPress = false;
			var substate = new ResetScoreSubState(curSong, curDisplay);
			substate.closeCallback = () -> {
				canPress = true;
			}
			openSubState(substate);
		}
		super.update(elapsed);
	}

	function set_curSelected(value:Int):Int {
		curSelected = value;
		if (value != -1) FlxG.sound.play(Paths.sound("channelOver", 'preload'), 0.7);
		return value;
	}
}