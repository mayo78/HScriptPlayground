package;

import flixel.util.FlxTimer;
import lime.app.Future;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.net.FileReference;
import openfl.events.Event;
import flixel.FlxG;
import flash.display.BitmapData;
import lime.media.AudioBuffer;
import flash.media.Sound;
import lime.system.Clipboard;

using StringTools;

class DragNDrop extends FlxState
{
  var hello:FlxText;
  var button:FlxSprite;
  var buttonTxt:FlxText;
  var clipboardButton:FlxSprite;
  var clipboardTxt:FlxText;
  var clipboardCodeButton:FlxSprite;
  var clipboardCodeTxt:FlxText;
  var curFile:FileReference;
  var loadedFiles:FlxText;
  var _cbCount:Int = 0;
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
    buttonTxt.setPosition(button.getMidpoint().x, button.getMidpoint().y - 8);
    add(buttonTxt);

    clipboardButton = new FlxSprite(button.x, button.y + 60).makeGraphic(100, 50, FlxColor.GRAY);
    add(clipboardButton);

    clipboardTxt = new FlxText(0, 0, 0, "Load file from clipboard link");
    clipboardTxt.alignment = 'center';
    clipboardTxt.setPosition(clipboardButton.getMidpoint().x, clipboardButton.getMidpoint().y - 8);
    add(clipboardTxt);

    clipboardCodeButton = new FlxSprite(clipboardButton.x, clipboardButton.y + 60).makeGraphic(100, 50, FlxColor.GRAY);
    add(clipboardCodeButton);

    clipboardCodeTxt = new FlxText(0, 0, 0, "Load file from clipboard");
    clipboardCodeTxt.alignment = 'center';
    clipboardCodeTxt.setPosition(clipboardCodeButton.getMidpoint().x, clipboardCodeButton.getMidpoint().y - 8);
    add(clipboardCodeTxt);
    
    loadedFiles = new FlxText(0, 0, 0, "Files loaded:");
    for(file in Upload.loaded) loadedFiles.text += '\n${file}';
    add(loadedFiles);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
    
    if(FlxG.mouse.justPressed)
    {
      if(FlxG.mouse.overlaps(button)){
        curFile = new FileReference();
        curFile.addEventListener(Event.SELECT, uploadedFile);
        curFile.addEventListener(Event.COMPLETE, loadedFile);
        curFile.browse();
      }else if(FlxG.mouse.overlaps(clipboardButton) || FlxG.mouse.overlaps(clipboardCodeButton)){
        @:privateAccess
        var myactual = Clipboard.get_text();
        if(myactual != null){
          if(FlxG.mouse.overlaps(clipboardCodeButton)){
            addFile(myactual, 'ClipboardCode_${_cbCount}', 'hx');
            _cbCount++;
          }else{
            var woah:Array<String> = myactual.split('/');
            var filename:String = woah[woah.length-1];
            var ok:Array<String> = filename.split('.');
            var ext:String = ok[ok.length-1];
            var name:String = [for(i in ok) if(i != ext) i].join('.');
            addFile(getUrlStuff(myactual), name, ext, filename);
          }
        }else{
          trace('WHY IT NULL! $myactual');
        }
      }
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
    addFile(curFile.data, fileName, fileExtension, curFile.name);
    curFile.removeEventListener(Event.COMPLETE, uploadedFile);
    curFile.removeEventListener(Event.SELECT, loadedFile);
    curFile = null;
  }
  function addFile(data:Dynamic, fileName:String, fileExtension:String, ?rawName:String) {
    if(rawName == null) rawName = fileName;
    switch(fileExtension) //do different things so its easier to load images and sounds
    {
      case 'hx': //add code to the whatever to execute
        PlayState.hscriptCode.set(fileName, Std.string(data));
      case 'png': //load the image and then add it to the upload stuff nice
        var loadingImage:Future<BitmapData> = BitmapData.loadFromBytes(data);
        filesLoadingQueue.push(fileName);
        loadingImage.onComplete(function(image) {
          filesLoadingQueue.remove(fileName);
          trace('file $fileName loaded succesfully!');
          Upload.loaded.push(rawName);
          Upload.graphics.set(fileName, image);
          loadedFiles.text += '\n${rawName}';
        });
      case 'mp3' | 'ogg' | 'wav': //same thing as image but weirder cause theres no built in loading future guy for sounds
        var loadingSound:Future<Sound> = new Future<Sound>(function(){
          return Sound.fromAudioBuffer(AudioBuffer.fromBytes(data));
        });
        filesLoadingQueue.push(fileName);
        loadingSound.onComplete(function(sound) {
          filesLoadingQueue.remove(fileName);
          trace('file $fileName loaded succesfully!');
          Upload.loaded.push(rawName);
          Upload.sounds.set(fileName, sound);
          loadedFiles.text += '\n${rawName}';
        });
      default: //just add the file to whatever
        Upload.set(rawName, data);
        loadedFiles.text += '\n${rawName}';
    }
  }

  function getUrlStuff(url:String) {
    var http = new haxe.Http(url);
    var r = null;

    http.onData = function (data:String)
    {
        r = data;
    }

    http.onError = function (error) {
        trace('error: $error');
    }

    http.request();
    return r;
}
}
