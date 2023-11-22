#if cpp
import cpp.ConstCharStar;
import cpp.Native;
import cpp.UInt64;
#end
import flixel.FlxG;
import lime.app.Application;
import openfl.system.Capabilities;

class SpecsDetector extends MusicBeatState
{
	var cache:Bool = false;
	var isCacheSupported:Bool = false;

	override public function create()
	{
		super.create();

		FlxG.save.data.cachestart = checkSpecs();
		/*if (FlxG.save.data.usernameForCrash == null || FlxG.save.data.usernameForCrash == '')
		{
			FlxG.switchState(new NameAsk());
		} else {*/
			FlxG.switchState(Type.createInstance(Main.initialState, []));
		//}
	}

	function checkSpecs():Bool
	{
		var cpu:Bool = Capabilities.supports64BitProcesses;

		trace('\n--- SYSTEM INFO ---\nCPU ${cpu ? "64": "32"} BITS');

		return true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}