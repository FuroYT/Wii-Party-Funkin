import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import lime.app.Application;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUITooltip;
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
	public static var curHovered:Int;
	static var discIntroSound:FlxSoundAsset =     Paths.music('channels/disc/intro');
	static var freeplayIntroSound:FlxSoundAsset = Paths.music('channels/freeplay/intro');
	static var freeplayLoopSound:FlxSoundAsset =  Paths.music('channels/freeplay/loop');
	static var galleryIntroSound:FlxSoundAsset =  Paths.music('channels/gallery/intro');
	static var creditsIntroSound:FlxSoundAsset =  Paths.music('channels/credits/intro');
	static var shopIntroSound:FlxSoundAsset =     Paths.music('channels/shop/intro');
	static var shopLoopSound:FlxSoundAsset =      Paths.music('channels/shop/loop');
	static var newsIntroSound:FlxSoundAsset =     Paths.music('channels/news/intro');
	static var optionsIntroSound:FlxSoundAsset =  Paths.music('channels/options/intro');
	static var optionsLoopSound:FlxSoundAsset =   Paths.music('channels/options/loop');
	static var discordIntroSound:FlxSoundAsset =  Paths.music('channels/discord/intro');
	static var homebrewIntroSound:FlxSoundAsset = Paths.music('channels/homebrew/intro');
	static var homebrewLoopSound:FlxSoundAsset =  Paths.music('channels/homebrew/loop');
	static var wiiMainMenuMusic:FlxSoundAsset =   Paths.music('freakyMenu');
	var launchButton:FlxButton;
	var backButton:FlxButton;
	var launchButtonSprite:FlxSprite;
	var backButtonSprite:FlxSprite;
	var inChannelMode:Bool = false;
	var blackScreen:FlxSprite;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var timeTxt:FlxText;

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

	var redirections:Map<String, Dynamic> = [
		'disc' => StoryDisk,
		'mii' => FreeplayState,
		'gallery' => GalleryState,
		'credits' => CreditsState,
		'shop' => ShopState,
		'news' => NewsState,
		'options' => options.OptionsState,
		'homebrew' => HomebrewMenu,
		'discord' => 'https://discord.gg/QvPfbPF83U'
	];

	var debugKeys:Array<FlxKey>;
	
	//for channel main UI & sound
	function makeChoicesEnter()
	{
		FlxTween.tween(launchButtonSprite, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(backButtonSprite, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(blackScreen, {alpha: 0.7}, 0.5, {ease: FlxEase.quadOut});
	}
	
	function playChannelMusic(introSound:FlxSoundAsset, loopSound:FlxSoundAsset)
	{
		if (loopSound == null) loopSound = wiiMainMenuMusic;
		FlxG.sound.music.fadeOut(0.7, 0, function(_){
			FlxG.sound.playMusic(introSound, 0);
			FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(loopSound, 0.8);};
		});
	}
	var canSelect:Bool = true;
	function launchMenu()
	{
		if (inChannelMode && canSelect)
		{
			canSelect = false;
			if (Std.isOfType(redirections.get(curSelected), String)) {
				CoolUtil.browserLoad(redirections.get(curSelected));
				canSelect = true;
				backMenu();
			} else {
				if (redirections.get(curSelected) != null)
					MusicBeatState.switchState(Type.createInstance(redirections.get(curSelected), []));
				else
					MusicBeatState.switchState(Type.createInstance(Type.getClass(this), []));
			}
		}
	}
	
	function backMenu()
	{
		if (inChannelMode && canSelect)
		{
			canSelect = false;
			FlxTween.tween(launchButtonSprite, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(backButtonSprite, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(blackScreen, {alpha: 0}, 0.5, {ease: FlxEase.quadOut, onComplete: function(_){
				canSelect = true;
				launchButtonSprite.animation.play("idle", true);
				backButtonSprite.animation.play("idle", true);
			}});
			@:privateAccess
			if (FlxG.sound.music._sound != wiiMainMenuMusic) {
				FlxG.sound.music.fadeOut(0.7, 0, function(_){
					FlxG.sound.playMusic(wiiMainMenuMusic, 0.5);
				});
			}
			inChannelMode = false;
			curSelected = "nuh uh";
		}
	}

	static function preloadChannelsMusic()
	{
		FlxG.sound.cache(discIntroSound);
		FlxG.sound.cache(freeplayIntroSound);
		FlxG.sound.cache(freeplayLoopSound);
		FlxG.sound.cache(galleryIntroSound);
		FlxG.sound.cache(creditsIntroSound);
		FlxG.sound.cache(shopIntroSound);
		FlxG.sound.cache(shopLoopSound);
		FlxG.sound.cache(newsIntroSound);
		FlxG.sound.cache(optionsIntroSound);
		FlxG.sound.cache(optionsLoopSound);
		FlxG.sound.cache(discordIntroSound);
		FlxG.sound.cache(homebrewIntroSound);
		FlxG.sound.cache(homebrewLoopSound);
		FlxG.sound.cache(wiiMainMenuMusic);
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

		var timePos = [550, FlxG.height - 80];
		timeTxt = new FlxText(timePos[0], timePos[1], 500, "", 48, true);
		timeTxt.color = FlxColor.BLACK;
		timeTxt.font = Paths.font("Delfino.ttf");
		add(timeTxt);

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

		launchButton = new FlxButton(750, 530, "Launch", null);
  		backButton = new FlxButton(300, 530, "Back", null);
  		launchButton.alpha = 0;
  		backButton.alpha = 0;

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

		launchButtonSprite = new FlxSprite(launchButton.x, launchButton.y - 20);
		launchButtonSprite.frames = Paths.getSparrowAtlas('mainmenu/start');
		launchButtonSprite.scrollFactor.set(0, 0);
		launchButtonSprite.setGraphicSize(Std.int(launchButton.width) + 50);
		launchButtonSprite.updateHitbox();
		launchButtonSprite.antialiasing = ClientPrefs.globalAntialiasing;
		launchButtonSprite.animation.addByPrefix("idle", "start0", 24, false, false, false);
		launchButtonSprite.animation.addByPrefix("press", "start press", 24, false, false, false);
		launchButtonSprite.animation.play("idle", true);
		launchButtonSprite.alpha = 0;
		add(launchButtonSprite);

		launchButton.onUp.callback = function() {
			if (!inChannelMode) return;
			if (launchButtonSprite.animation.curAnim.name == "press") return;
			launchButtonSprite.animation.play("press", true);
			launchButtonSprite.offset.set(155, 42);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			launchButtonSprite.animation.finishCallback = function(_){launchMenu();};
		}

		backButtonSprite = new FlxSprite(backButton.x, backButton.y - 20);
		backButtonSprite.frames = Paths.getSparrowAtlas('mainmenu/menu');
		backButtonSprite.scrollFactor.set(0, 0);
		backButtonSprite.setGraphicSize(Std.int(backButton.width) + 50);
		backButtonSprite.updateHitbox();
		backButtonSprite.antialiasing = ClientPrefs.globalAntialiasing;
		backButtonSprite.animation.addByPrefix("idle", "menu0", 24, true, false, false);
		backButtonSprite.animation.addByPrefix("press", "menu press", 24, false, false, false);
		backButtonSprite.animation.play("idle", true);
		backButtonSprite.alpha = 0;
		add(backButtonSprite);

		backButton.onUp.callback = function() {
			if (!inChannelMode) return;
			if (backButtonSprite.animation.curAnim.name == "press") return;
			backButtonSprite.animation.play("press", true);
			backButtonSprite.offset.set(152, 42);
			backButtonSprite.animation.finishCallback = function(_){
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.7);
				backMenu();
				backButtonSprite.animation.play("idle", true);
			};
		}

		new FlxTimer().start(1, function(timer:FlxTimer){
			beatShit++;
			theColon = beatShit % 2 == 1 ? ":" : " ";
			timer.reset(1);
		});

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
				selectMenu('disc', discIntroSound, null);
			case 1:
				selectMenu('mii', freeplayIntroSound, freeplayLoopSound);
			case 2:
				selectMenu('gallery', galleryIntroSound, null);
			case 3:
				selectMenu('credits', creditsIntroSound, null);
			case 4:
				selectMenu('shop', shopIntroSound, shopLoopSound);
			case 5:
				selectMenu('news', newsIntroSound, null);
			case 6:
				selectMenu('options', optionsIntroSound, optionsLoopSound);
			case 7:
				selectMenu('homebrew', homebrewIntroSound, homebrewLoopSound);
			case 8:
				selectMenu('discord', discordIntroSound, null);
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

	function mouseHover(daSelection:Int)
	{
		if (curHovered == daSelection)
			return;
		curHovered = daSelection;
	}
	var coolSwag:Int = 0;
	var beatShit:Int = 0;
	var theColon:String = " ";
	function formatDate(date:Int)
	{
		if (Std.string(date).length == 1)
			return "0" + Std.string(date);
		else
			return Std.string(date);
	}
	override function update(elapsed:Float)
	{
		var date = Date.now();
		timeTxt.text = '${formatDate(date.getHours())}${theColon}${formatDate(date.getMinutes());}';
		if (FlxG.keys.anyJustPressed(debugKeys)) MusicBeatState.switchState(new editors.MasterEditorMenu());
		if (FlxG.keys.justPressed.C) MusicBeatState.switchState(new test.DiscordRPCIconTest());
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
    	if (canSelect && (((FlxG.mouse.justPressed || wiimoteReadout.buttons.a) && (!inChannelMode && (!FlxG.mouse.overlaps(launchButton) && !FlxG.mouse.overlaps(backButton)))) && curSelected2 != -1)) select();
		if (!mouseShit()) curSelected2 = -1;
		FlxG.watch.addQuick('inChannelMode', (inChannelMode ? 'yes' : 'no'));
		if (FlxG.keys.justPressed.P) {
			coolSwag++;
			MouseCursors.loadCursor((coolSwag % 2 == 1 ? 'homebrew' : 'normal'));
		}
		super.update(elapsed);
	}
}
