package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var selector:FlxText;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var bottomText:FlxText;
	var bg:FlxSprite;

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

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		bottomText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 24);
		bottomText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);
		bottomText.scrollFactor.set();
		add(bottomText);
		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;

	function mouseShit()
	{
		for (item in 0...menuItemsToAddBitch.length) {
			var spr = menuItemsToAddBitch[item][3];
			if (FlxG.mouse.overlaps(spr))
			{
				bottomText.text = 'Current Selected Song: "${menuItemsToAddBitch[item][2]}"';
				if (FlxG.mouse.justPressed) {
					startSong(menuItemsToAddBitch[item][2]);
				}
			}
		}
	}

	function startSong(songName:String) {
		persistentUpdate = false;
		PlayState.SONG = Song.loadFromJson(songName, songName);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
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

		mouseShit();

		PlayState.currentHUD = (FlxG.keys.pressed.C ? MARIO_KART : DEFAULT);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		#if debug
		var ctrl = FlxG.keys.justPressed.CONTROL;
		#end

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.fadeOut(0.3, 0, function(_){
				@:privateAccess
				FlxG.sound.playMusic(MainMenuState.wiiMainMenuMusic, 0, true);
				MusicBeatState.switchState(new MainMenuState());
			});
		}
		super.update(elapsed);
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}