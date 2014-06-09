package ui;

import db.Manga;

import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.style.Style;
import haxe.ui.toolkit.style.StyleManager;
import haxe.ui.toolkit.containers.HBox;

import sys.db.Manager;

class UIMain
{
	var imgViewer:ImageViewer;
	public function new()
	{
		Toolkit.init();
		Toolkit.openFullscreen(
			function(root:Root) 
			{
				StyleManager.instance.addStyle("#imgViewer, .imgViewer", new Style({
					width: 400,
					height: root.height,
					backgroundColor:0x00ff00,
					autoSize:false,
					autoSizeSet:false
				}));
				
				StyleManager.instance.addStyle("#controls, .controls", new Style({
					width: root.width-400,
					height: root.height,
					backgroundColor:0x0000ff,
					autoSize:false,
					autoSizeSet:false
				}));
				
				StyleManager.instance.addStyle(".dropdown", new Style({
					width: root.width-400,
					selectionMethod: "default"
				}));
				
				var box = new HBox();
				
				imgViewer = new ImageViewer();
				imgViewer.styleName = "imgViewer";
				box.addChild(imgViewer);
			
				var controls = new Controls(imgViewer);
				controls.styleName = "controls";
				box.addChild(controls);
				
				box.addEventListener(UIEvent.DEACTIVATE, function (e)
				{
					trace("bye");
					for (m in Manga.manager.all())
					{
						m.update();
					}
					Manager.cleanup();
				});
				
				root.addChild(box);
			});
			
			
	}
	
}
