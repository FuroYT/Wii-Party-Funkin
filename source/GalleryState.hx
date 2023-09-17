package;

import Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Json;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;
typedef ImageData =
{
	var path:String;
	var scale:Float;
	var description:String;
	var artist:String;
}

class GalleryState extends MusicBeatState
{
	static var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var itemsData:Array<ImageData> = [];
	var artist:FlxText;
	var description:FlxText;
	var arrowRight:FlxSprite;
	var arrowLeft:FlxSprite;
    var canPress:Bool = true;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Gallery Menu", null);
		#end

		FlxG.mouse.visible = true;
		
		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('gallery/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var fullText:String = Assets.getText(Paths.json('gallery/list', "preload", "images"));
		var firstArray:Array<String> = fullText.split('},');
		for (i in 0...firstArray.length)
		{
			if (!firstArray[i].endsWith('}'))
				firstArray[i] += "}";
			var daData:ImageData = cast Json.parse(firstArray[i]);
			itemsData.push(daData);
			var daItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gallery/images/' + itemsData[i].path));
			daItem.scale.set(itemsData[i].scale, itemsData[i].scale);
			daItem.updateHitbox();
			daItem.screenCenter();
			daItem.ID = i;
			menuItems.add(daItem);
		}
		
		var barTop:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 100, 0xFF000000);
		barTop.updateHitbox();
		barTop.x = 0;
		barTop.y = 0;
		add(barTop);

		var barBot:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(barTop.height), 0xFF000000);
		barBot.updateHitbox();
		barBot.x = 0;
		barBot.y = FlxG.height - barBot.height;
		add(barBot);

		arrowLeft = new FlxSprite().loadGraphic(Paths.image('gallery/arrow'));
		arrowLeft.scale.set(5, 5);
		arrowLeft.updateHitbox();
		arrowLeft.x = 50;
		arrowLeft.screenCenter(Y);
		add(arrowLeft);

		arrowRight = new FlxSprite().loadGraphic(Paths.image('gallery/arrow'));
		arrowRight.scale.set(5, 5);
		arrowRight.updateHitbox();
		arrowRight.flipX = true;
		arrowRight.x = FlxG.width - arrowRight.width - 50;
		arrowRight.screenCenter(Y);
		add(arrowRight);
		
		artist = new FlxText(0, 30, FlxG.width, 'Made By:' , 26);
		artist.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER);
		add(artist);
		
		description = new FlxText(0, FlxG.height - 80, FlxG.width - 200, '' , 40);
		description.updateHitbox();
		description.screenCenter(X);
		description.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER);
		add(description);

		changeSelection();

		FlxG.sound.music.fadeOut(0.3, 0, function(_){
            FlxG.sound.playMusic(Paths.music("channels/gallery/bgm"), 0.8);
			FlxG.sound.music.onComplete = function () {FlxG.sound.playMusic(Paths.music("channels/gallery/bgm"), 0.8);};
        });

		super.create();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);

		if ((controls.UI_LEFT_P || (FlxG.mouse.overlaps(arrowLeft) && FlxG.mouse.justPressed)) && canPress) {
			changeSelection(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if ((controls.UI_RIGHT_P || (FlxG.mouse.overlaps(arrowRight) && FlxG.mouse.justPressed)) && canPress) {
			changeSelection(1);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if ((controls.BACK) && canPress) {
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
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = itemsData.length - 1;
		if (curSelected >= itemsData.length)
			curSelected = 0;

		artist.text = 'Made by: ' + itemsData[curSelected].artist;
		description.text = itemsData[curSelected].description;

		for (daItem in menuItems.members) {
			daItem.visible = (daItem.ID == curSelected);
		}
	}
}