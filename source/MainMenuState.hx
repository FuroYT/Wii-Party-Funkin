import flixel.system.FlxSound;
import lime.app.Application;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.ui.FlxButton;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import Achievements;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var modVersion:String = "3.0.0";
	public static var curSelected:String = "nuh uh";
	public static var curSelected2:Int;
	static var homebrewIntroSound:FlxSoundAsset = Paths.music('homebrew/intro');
	static var homebrewLoopSound:FlxSoundAsset = Paths.music('homebrew/loop');
	static var wiiMainMenuMusic:FlxSoundAsset = Paths.music('freakyMenu');
	var toolBar:FlxSprite;
	var launchButton:FlxButton;
	var backButton:FlxButton;
	var inChannelMode:Bool = false;
	var blackScreen:FlxSprite;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var menuItemsToAddBitch:Array<Dynamic> = [
		[140, 30, 'disc'],
		[475, 30, 'freeplay'],
		[FlxG.width - 475, 30, 'gallery'],
		[140, 270, 'credits'],
		[475, 270, 'shop'],
		[FlxG.width - 475, 270, 'news'],
		[FlxG.width - 345, FlxG.height - 175, 'options'],
		[FlxG.width - 475, FlxG.height - 175, 'homebrew'],
		[FlxG.width - 200, FlxG.height - 180, 'discord']
	];

	var debugKeys:Array<FlxKey>;
	
	//for channel main UI & sound
	function makeChoicesEnter()
	{
		FlxTween.tween(launchButton, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(blackScreen, {alpha: 0.7}, 0.5, {ease: FlxEase.quadOut});
	}
	
	function playChannelMusic(introSound, loopSound)
	{
		FlxG.sound.music.fadeOut(0.7, 0, function(_){
			FlxG.sound.playMusic(introSound, 0.5);
			FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(loopSound, 0.8);};
		});
	}
	
	function launchMenu()
	{
		if (inChannelMode)
		{
			switch (curSelected)
			{
				case 'disc':
					MusicBeatState.switchState(new StoryDisk());
				case 'mii':
					MusicBeatState.switchState(new FreeplayState());
				case 'gallery':
					//open the gallery menu
				case 'credits':
					MusicBeatState.switchState(new CreditsState());
				case 'shop':
					//open the goddamn shop
				case 'news':
					//ive come to make an announcement
				case 'options':
					LoadingState.loadAndSwitchState(new options.OptionsState());
				case 'homebrew':
					//yuh uh
				case 'discord':
					CoolUtil.browserLoad('https://discord.gg/xA2envhqWs');
				default:
					FlxG.resetState(); //when the option doesnt exist
			}
		}
	}
	
	function backMenu()
	{
		if (inChannelMode)
		{
			FlxTween.tween(launchButton, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(backButton, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(blackScreen, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxG.sound.music.fadeOut(0.7, 0, function(_){
				FlxG.sound.playMusic(wiiMainMenuMusic, 0.5);
			});
			inChannelMode = false;
			curSelected = "nuh uh";
		}
	}

	static function preloadChannelsMusic()
	{
		new FlxSound().loadEmbedded(homebrewIntroSound);
		new FlxSound().loadEmbedded(homebrewLoopSound);
		new FlxSound().loadEmbedded(wiiMainMenuMusic);
	}

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		FlxG.mouse.visible = true;

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Wii Party Funkin' v" + modVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		/*#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end*/

		for (item in 0...menuItemsToAddBitch.length) {
			var sprite = new FlxSprite(menuItemsToAddBitch[item][0], menuItemsToAddBitch[item][1]).loadGraphic(Paths.image('mainmenu/${menuItemsToAddBitch[item][2]}'));
			add(sprite);
			sprite.ID = item;
			menuItemsToAddBitch[item].push(sprite);
		}

		blackScreen = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0;
		add(blackScreen);

		launchButton = new FlxButton(750, 530, "Launch", launchMenu);
  		backButton = new FlxButton(300, 530, "Back", backMenu);
  		launchButton.alpha = 0;
  		backButton.alpha = 0;
  		//launchButton.size = 5;
  		//backButton.size = 5;
  		launchButton.scale.scale(3);
  		backButton.scale.scale(3);
  		launchButton.label.setFormat(null, 32, 0x333333, "center");
  		backButton.label.setFormat(null, 32, 0x333333, "center");
  		launchButton.updateHitbox();
  		backButton.updateHitbox();
  		launchButton.label.updateHitbox();
  		backButton.label.updateHitbox();
  		launchButton.label.fieldWidth = launchButton.width;
  		backButton.label.fieldWidth = backButton.width;
  		launchButton.scrollFactor.set(0, 0);
  		backButton.scrollFactor.set(0, 0);
  		add(launchButton);
  		add(backButton);

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	function select() {
		switch(curSelected2)
		{
			case 0:
				selectMenu('disc', null, null);
			case 1:
				selectMenu('mii', null, null);
			case 2:
				selectMenu('gallery', null, null);
			case 3:
				selectMenu('credits', null, null);
			case 4:
				selectMenu('shop', null, null);
			case 5:
				selectMenu('news', null, null);
			case 6:
				selectMenu('options', null, null);
			case 7:
				selectMenu('homebrew', homebrewIntroSound, homebrewLoopSound);
			case 8:
				selectMenu('discord', null, null);
			default:
				FlxG.resetState(); //when the option doesnt exist
		}
	}

	function selectMenu(selection:String, introSound:FlxSoundAsset, loopSound:FlxSoundAsset)
	{
		curSelected = selection;
		makeChoicesEnter();
		inChannelMode = true;
		playChannelMusic(introSound, loopSound);

	}

	function mouseShit()
	{
		var things = ['disc', 'mii', 'gallery', 'credits', 'shop', 'news', 'options', 'homebrew', 'discord'];
		var coolSwag = things[curSelected2];
		if (curSelected2 == -1) coolSwag = "None";
		FlxG.watch.addQuick('curSelected', curSelected);
		FlxG.watch.addQuick('curSelected2String', coolSwag);
		FlxG.watch.addQuick('curSelected2', curSelected2);
		for (item in 0...menuItemsToAddBitch.length) {
			var spr = menuItemsToAddBitch[item][3];
			if (FlxG.mouse.overlaps(spr))
			{
				curSelected2 = spr.ID;
				return true;
			}
		}
		return false;
	}
	var coolSwag:Int = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.C) MusicBeatState.switchState(new test.DiscordRPCIconTest());
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
    	if (((FlxG.mouse.justPressed || wiimoteReadout.buttons.a) && (!inChannelMode && (!FlxG.mouse.overlaps(launchButton) && !FlxG.mouse.overlaps(backButton)))) && curSelected2 != -1) select();
		if (!mouseShit()) curSelected2 = -1;
		FlxG.watch.addQuick('inChannelMode', (inChannelMode ? 'yes' : 'no'));
		if (FlxG.keys.justPressed.P) {
			coolSwag++;
			MouseCursors.loadCursor((coolSwag % 2 == 1 ? 'homebrew' : 'normal'));
		}
		super.update(elapsed);
	}
}
