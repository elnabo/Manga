package ui;

import sys.FileSystem;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.events.UIEvent;

import db.Manga;
import web.Download;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Controls extends VBox
{
	var viewer:ImageViewer;
	var txtInput:TextInput;
	var button:Button;
	
	public function new(?viewer:ImageViewer)
	{
		super();
		this.viewer = viewer;
		
		txtInput = new TextInput();
		button = new Button();
		button.text="Download";
		button.addEventListener(UIEvent.CLICK, function(e:UIEvent)
			{
				Thread.create(function(){
				Download.download(txtInput.text);});
			});
		
		
		var l = new DropDownList();
		l.addEventListener(UIEvent.CHANGE, function(e:UIEvent)
		{
			var self = e.getComponentAs(DropDownList);
			var manga = Manga.get(self.text);
			viewer.display(self.text,manga.currentChapterRead,manga.currentPageRead);
		});
		
		addChild(txtInput);
		addChild(button);
		addChild(l);
	}
}
