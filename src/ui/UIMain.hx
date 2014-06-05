package ui;

import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.style.Style;
import haxe.ui.toolkit.style.StyleManager;
import haxe.ui.toolkit.containers.HBox;
//~ import haxe.ui.toolkit.controls.Button;
//~ import haxe.ui.toolkit.controls.Image;
//~ import flash.events.MouseEvent;
//~ import flash.display.BitmapData;
//~ import haxe.ui.toolkit.core.Macros;


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
				
				var box = new HBox();
				
				imgViewer = new ImageViewer();
				imgViewer.styleName = "imgViewer";
				box.addChild(imgViewer);
				//~ root.addChild(imgViewer);
			
				var controls = new Controls();
				controls.styleName = "controls";
				box.addChild(controls);
				
				root.addChild(box);
			});
		imgViewer.display("phantom-brave-ivoire-monogatari",1,1);
	}
	
}
