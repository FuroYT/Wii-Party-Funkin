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
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var debugKeys:Array<FlxKey>;
	
	//for channel main UI & sound
	function makeChoicesEnter()
	{
		FlxTween.tween(launchButton, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(blackScreen, {alpha: 0.7}, 0.5, {ease: FlxEase.quadOut});
	}
	
	function playLoop(loopSound)
	{
		FlxG.sound.playMusic(loopSound, 0.8);
	}
	
	function playChannelMusic(introSound, loopSound)
	{
		FlxG.sound.music.fadeOut(0.7, 0, function(_){
			FlxG.sound.playMusic(introSound, 0.5);
			FlxG.sound.music.onComplete = function () {playLoop(loopSound);};
		});
	}
	
	function launchMenu()
	{
		if (inChannelMode)
		{
			switch (curSelected)
			{
				case 'disc':
					MusicBeatState.switchState(new DiskWeekTest());
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

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('toolbar'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		FlxG.mouse.visible = true;

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
				selectMenu('homebrew', null, null);
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

	function mouseShit(mouseX:Float, mouseY:Float)
	{
		var things = ['disc', 'mii', 'gallery', 'credits', 'shop', 'news', 'options', 'homebrew', 'discord'];
		FlxG.watch.addQuick('MouseX', mouseX);
		FlxG.watch.addQuick('MouseY', mouseY);
		var coolSwag = things[curSelected2];
		if (curSelected2 == -1) coolSwag = "None";
		FlxG.watch.addQuick('curSelected', curSelected);
		FlxG.watch.addQuick('curSelected2String', coolSwag);
		FlxG.watch.addQuick('curSelected2', curSelected2);
		if ((mouseX >= 145 && mouseX <= 455) && (mouseY >= 65 && mouseY <= 260))
		{
			curSelected2 = 0;
			return;
		} else if ((mouseX >= 485 && mouseX <= 790) && (mouseY >= 65 && mouseY <= 260))
		{
			curSelected2 = 1;
			return;
		} else if ((mouseX >= 815 && mouseX <= 1125) && (mouseY >= 65 && mouseY <= 260))
		{
			curSelected2 = 2;
			return;
		}
		else if ((mouseX >= 145 && mouseX <= 455) && (mouseY >= 300 && mouseY <= 495))
		{
			curSelected2 = 3;
			return;
		} else if ((mouseX >= 485 && mouseX <= 790) && (mouseY >= 300 && mouseY <= 495))
		{
			curSelected2 = 4;
			return;
		} else if ((mouseX >= 815 && mouseX <= 1125) && (mouseY >= 300 && mouseY <= 495))
		{
			curSelected2 = 5;
			return;
		} else if ((mouseX >= 1085 && mouseX <= 1225) && (mouseY >= 570 && mouseY <= 705))
		{
			curSelected2 = 8;
			return;
		} else {
			curSelected2 = -1;
			return;
		}
	}
	var coolSwag:Int = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
    	if (((FlxG.mouse.justPressed || wiimoteReadout.buttons.a) && (!inChannelMode && (!FlxG.mouse.overlaps(launchButton) && !FlxG.mouse.overlaps(backButton)))) && curSelected2 != -1) select();
		mouseShit(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
		FlxG.watch.addQuick('inChannelMode', (inChannelMode ? 'yes' : 'no'));
		if (FlxG.keys.justPressed.P) {
			coolSwag++;
			MouseCursors.loadCursor((coolSwag % 2 == 1 ? 'homebrew' : 'normal'));
		}
		super.update(elapsed);
	}
}
