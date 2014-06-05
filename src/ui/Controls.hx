package ui;

import sys.FileSystem;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.events.UIEvent;

import web.Download;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Controls extends VBox
{
	var txtInput:TextInput;
	var button:Button;
	
	public function new()
	{
		super();
		txtInput = new TextInput();
		button = new Button();
		button.text="Download";
		button.addEventListener(UIEvent.CLICK, function(e:UIEvent)
			{
				Thread.create(function(){
				Download.download(txtInput.text);});
				trace("need to download",txtInput.text);
			});
		
		addChild(txtInput);
		addChild(button);
	}
}
