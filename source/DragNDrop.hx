package;

import flixel.util.FlxTimer;
import lime.app.Future;
import flixel.FlxState;
import js.html.Clipboard;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.net.FileReference;
import openfl.events.Event;
import flixel.FlxG;
import flash.display.BitmapData;
import openfl.utils.ByteArray;
import flixel.system.FlxSound;
import lime.media.AudioBuffer;
import flash.media.Sound;

using StringTools;

class DragNDrop extends FlxState
{
  var hello:FlxText;
  var button:FlxSprite;
  var buttonTxt:FlxText;
  var curFile:FileReference;
  var loadedFiles:FlxText;
	override public function create()
	{
		super.create();
    hello = new FlxText(0, 0, 0, "
    Click the button labeled to upload an image/other file\n
    The code will be loaded from your clipboard\n
    Press ENTER to run the code!\n
    Also, press BACKSPACE to leave PlayState!
    ");
    hello.alignment = 'center';
    hello.screenCenter();
    hello.y -= 50;
    add(hello);
    
    button = new FlxSprite().makeGraphic(100, 50, FlxColor.GRAY);
    button.screenCenter();
    button.y += 50;
    add(button);
    
    buttonTxt = new FlxText(0, 0, 0, "Upload");
    buttonTxt.alignment = 'center';
    buttonTxt.setPosition(button.getMidpoint().x, button.getMidpoint().y - 16);
    add(buttonTxt);
    
    loadedFiles = new FlxText(0, 0, 0, "Files loaded:");
    for(file in Upload.loaded) loadedFiles.text += '\n${file}';
    add(loadedFiles);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
    
    if(FlxG.mouse.overlaps(button) && FlxG.mouse.justPressed)
    {
      curFile = new FileReference();
      curFile.addEventListener(Event.SELECT, uploadedFile);
      curFile.addEventListener(Event.COMPLETE, loadedFile);
      curFile.browse();
    }
    if(FlxG.keys.justPressed.ENTER){
      if(filesLoadingQueue.length > 0)
      {
        var stillLoading:FlxText = new FlxText(0, 0, 0, 'Theres still a file being loaded!');
        add(stillLoading);
        new FlxTimer().start(0.5, function(tmr:FlxTimer) {
          stillLoading.destroy();
        });
      }
      FlxG.switchState(new PlayState());
    }
	}
  
  function uploadedFile(_):Void
  {
    curFile.load();
  }
  var filesLoadingQueue:Array<String> = [];
  function loadedFile(_):Void
  {
    var stupidArray:Array<String> = curFile.name.split('.');
    var fileExtension:String = stupidArray[stupidArray.length-1];
    var fileName:String = [for(i in stupidArray) if(i != fileExtension) i].join('.');
    trace('uploaded file ${curFile.name} detected file extension: ${fileExtension} name: ${fileName}');
    
    switch(fileExtension) //do different things so its easier to load images and sounds
    {
      case 'hx': //add code to the whatever to execute
        PlayState.hscriptCode.set(fileName, Std.string(curFile.data));
      case 'png': //load the image and then add it to the upload stuff nice
        var loadingImage:Future<BitmapData> = BitmapData.loadFromBytes(curFile.data);
        filesLoadingQueue.push(fileName);
        loadingImage.onComplete(function(image) {
          filesLoadingQueue.remove(fileName);
          trace('file $fileName loaded succesfully!');
          Upload.loaded.push(curFile.name);
          Upload.graphics.set(fileName, image);
          loadedFiles.text += '\n${curFile.name}';
        });
      case 'mp3' | 'ogg' | 'wav': //same thing as image but weirder cause theres no built in loading future guy for sounds
        var loadingSound:Future<Sound> = new Future<Sound>(function(){
          return Sound.fromAudioBuffer(AudioBuffer.fromBytes(curFile.data));
        });
        filesLoadingQueue.push(fileName);
        loadingSound.onComplete(function(sound) {
          filesLoadingQueue.remove(fileName);
          trace('file $fileName loaded succesfully!');
          Upload.loaded.push(curFile.name);
          Upload.sounds.set(fileName, sound);
          loadedFiles.text += '\n${curFile.name}';
        });
      default: //just add the file to whatever
        Upload.set(curFile.name, curFile.data);
        loadedFiles.text += '\n${curFile.name}';
    }
    curFile.removeEventListener(Event.COMPLETE, uploadedFile);
    curFile.removeEventListener(Event.SELECT, loadedFile);
    curFile = null;
  }
}
