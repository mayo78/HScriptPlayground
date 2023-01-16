import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import flixel.group.FlxGroup.FlxTypedGroup;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import Type.ValueType;

#if hscript
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
#end
class HScript
{
	public static var parser:Parser = new Parser();
	public var interp:Interp;

	public function new(code:String)
	{
		interp = new Interp();
		set('FlxG', FlxG);
		set('Math', Math);
		set('FlxSprite', FlxSprite);
		set('FlxCamera', FlxCamera);
		set('FlxTimer', FlxTimer);
		set('FlxTween', FlxTween);
		set('FlxEase', FlxEase);
		set('PlayState', PlayState);
		set('game', PlayState.instance);
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);
		set('this', this);
    set('Upload', Upload);
    set('getHScript', function(name:String) {
      if(!PlayState.instance.hscriptArray.exists(name)) return error(name, 'Script doesn\'t exist');
      return PlayState.instance.hscriptArray.get(name);
    });
    set('FlxTypedGroup', FlxTypedGroup);
		execute(code);
	}
	public function call(sfunc:String, ?args:Array<Dynamic>)
	{
		var ret = null;
		if(exists(sfunc))
		{
			var func = get(sfunc);
			if(args == null || args.length == 0)
			{
				try{
					ret = func();
				}catch(e:Dynamic){
					error(e, 'Error calling on HScript (no arguments)');
				}
			}
			else
			{
				try{
					ret = Reflect.callMethod(null, func, args);
				}catch(e:Dynamic){
					error(e, 'Error calling on HScript (arguments)');
				}
			}
		}
		return ret;
	}
	public inline function get(variable:String)
		return interp.variables.get(variable);
	public inline function set(variable:String, value:Dynamic)
		interp.variables.set(variable, value);
	public inline function exists(variable)
		return interp.variables.exists(variable);
	inline function error(e:Dynamic, type:String)
	{
		PlayState.instance.error('${type}: ${e.toString()}');
		trace('${e.toString()}');
		return null;
	}
	public function execute(codeToRun:String):Dynamic
	{
		try{
			@:privateAccess
			HScript.parser.line = 1;
			HScript.parser.allowTypes = true;
			return interp.execute(HScript.parser.parseString(codeToRun));
		}catch(e:Dynamic){
			error(e, 'Error executing');
			return null;
		}
	}
}