package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	public static var instance:PlayState;
	public static var hscriptCode:Map<String,String> = new Map<String,String>();
	public var hscriptArray:Map<String,HScript> = new Map<String,HScript>();
	override public function create()
	{
		super.create();
		instance = this;
		for(key in hscriptCode.keys())
			hscriptArray.set(key, new HScript(hscriptCode.get(key)));
		call('create');
	}
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
    if(FlxG.keys.justPressed.BACKSPACE)
      FlxG.switchState(new DragNDrop());
		call('update', [elapsed]);
	}
	public function error(e:String)
	{
		trace(e);
	}
	public function call(func:String, ?args:Array<Dynamic>)
	{
		var ret = null;
		for(hscript in hscriptArray)
		{
			var coolRet = hscript.call(func, args);
			if(coolRet != null)
				ret = coolRet;
		}
		return ret;
	}
	public function getFile(name:String) //it gets all weird if you do this stuff directly
		return Upload.get(name);
	public function playSound(name:String):Void
		FlxG.sound.play(Upload.sounds.get(name));
	public function sprite(x:Float, y:Float, image:String):FlxSprite
		return new FlxSprite(x, y).loadGraphic(Upload.graphics.get(image));
}
