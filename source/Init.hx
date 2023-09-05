package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import lime.app.Application;
import openfl.Lib;
import Discord.DiscordClient;

class Init extends FlxState
{
	public override function new()
	{
		super();
	}

	public override function create()
	{
		super.create();

		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end

		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

		FlxG.autoPause = false;

		PlayerSettings.reset();

		PlayerSettings.init();

		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;

		#if desktop
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		ClientPrefs.loadDefaultKeys();

		#if !html5
		FlxG.switchState(Type.createInstance(SpecsDetector, []));
		#else
		FlxG.switchState(Type.createInstance(Main.initialState, []));
		#end
	}
}