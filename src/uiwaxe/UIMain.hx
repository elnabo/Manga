package uiwaxe;

import db.Manga;
import sys.db.Manager;

import wx.App;
import wx.FlexGridSizer;
import wx.Frame;
import wx.Sizer;

class UIMain
{
	var mFrame:Frame;
	
	public function new()
	{
		var mFrame = Frame.create(null, null, "Manga", null, { width: 800, height: 600 });	
		var imgViewer = new ImageViewer(mFrame,null,{x:0,y:0}, {width:600,height:600});
		
		App.setTopWindow(mFrame);
		mFrame.shown = true;
		mFrame.onClose = function (_) 
			{ 
				for (m in Manga.manager.all())
				{
					m.update();
				}
				Manager.cleanup();
				App.quit();
			};
		
		var ctrl = new Controls(imgViewer,mFrame,null,{x:600,y:0}, {width:200,height:600});
		
		var sizer = FlexGridSizer.create(null,2);
		
		sizer.add(imgViewer,0,0,0);
		sizer.add(ctrl,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,4);	
		
		sizer.fit(mFrame);
		sizer.setSizeHints(mFrame);
		mFrame.sizer = sizer;
	}
}
