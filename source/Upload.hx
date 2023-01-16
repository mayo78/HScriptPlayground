//for uplaoded stuff
import flash.display.BitmapData;
import flash.media.Sound;

class Upload
{
  public static var data:Map<String, Dynamic> = new Map<String, Dynamic>();
  public static var sounds:Map<String,Sound> = new Map<String,Sound>();
  public static var graphics:Map<String,BitmapData> = new Map<String,BitmapData>();
  inline public static function get(name:String){
    return data.get(name);
  }
  inline public static function set(name:String, variable:Dynamic){
    data.set(name, variable);
  }
  inline public static function exists(name:String):Bool{
    return data.exists(name);
  }
}