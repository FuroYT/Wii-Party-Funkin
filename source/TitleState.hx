import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
import lime.app.Application;
#end
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxTimer;
using StringTools;
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	var canPressA:Bool = false;
	var group:FlxTypedGroup<FlxSprite>;
	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		PlayerSettings.init();
		super.create();
		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();
		Highscore.load();
		if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
		persistentUpdate = true;
		persistentDraw = true;
		if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end

		group = new FlxTypedGroup<FlxSprite>();
		add(group);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startGame();
		});
	}

	function startGame()
	{
		group.forEachAlive(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 1}, 2, {ease: FlxEase.cubeIn});
		}, true);
		new FlxTimer().start(2, function(_) {
			var text = new flixel.addons.ui.FlxUIText(60, 235, FlxG.width, "Press enter to go to main menu", 24);
			text.autoSize = false;
			text.alignment = CENTER;
			add(text);
			canPressA = true;
		});
	}

	override function update(elapsed:Float)
	{
		var pressedAonWiimote:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed) pressedAonWiimote = true;
		}
		#end
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null && ((gamepad.justPressed.START #if switch || gamepad.justPressed.B #end ) || wiimoteReadout.buttons.a)) pressedAonWiimote = true;
		if(pressedAonWiimote && canPressA)
		{
			canPressA = false;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				@:privateAccess
				MainMenuState.preloadChannelsMusic();
				MusicBeatState.switchState(new MainMenuState());
				@:privateAccess
				FlxG.sound.playMusic(MainMenuState.wiiMainMenuMusic, 0, true);
			});
		}
		super.update(elapsed);
	}
}
