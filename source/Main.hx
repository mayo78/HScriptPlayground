package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;

// #if debug
// import luxe.Input;
// import luxe.Vector;
// import luxe.Text;
// #end
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = DragNDrop; // The FlxState the game starts with.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	#if (flixel < "5.0.0")
	flixel 4.11 users deserve DEATH!!!!!!!! update to flixel 5 already idiot
	#end
	public function new()
	{
		super();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));
	}
}
