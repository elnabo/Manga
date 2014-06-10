package uiwaxe;

import db.Manga;
import sys.db.Manager;

import wx.App;
import wx.Dialog;
import wx.EventID;
import wx.FlexGridSizer;
import wx.Frame;
import wx.Menu;
import wx.MenuBar;
import wx.Sizer;
import wx.Window;

class UIMain
{
	var imgViewer:ImageViewer;
	var mFrame:Frame;
	
	public function new()
	{
		mFrame = Frame.create(null, null, "Manga", null, { width: 800, height: 600 });	
		imgViewer = new ImageViewer(mFrame,null,{x:0,y:0}, {width:600,height:600});
		
		App.setTopWindow(mFrame);
		mFrame.shown = true;
		mFrame.onClose = close;
			
		var menu = new MenuBar();
		var id = 0;
		
		var file = new Menu("",0);
		file.append(id,"Open","Open something");
		mFrame.handle(id++, function (_) {trace("rrr");});
		
		file.append(id,"Exit","Exit the application");
		mFrame.handle(id++, close);
		menu.append(file,"File");
		
		var manga = new Menu("",1);
		manga.append(id,"Download", "Download a manga");
		mFrame.handle(id++, function (_) 
			{
				new DownloadDialog(mFrame,null,"Download a manga",{width:300,height:200});
			});
		manga.append(id,"Read a manga", "");
		mFrame.handle(id++, function (_) 
			{
				new ChooserDialog(imgViewer,mFrame,null,"Choose a manga",{width:300,height:200});
			});
		menu.append(manga,"Manga");
		
		

		mFrame.menuBar = menu;
		//~ var ctrl = new Controls(imgViewer,mFrame,null,{x:600,y:0}, {width:200,height:600});
		//~ var sizer = FlexGridSizer.create(null,2);
		//~ 
		//~ sizer.add(imgViewer,0,0,0);
		//~ sizer.add(ctrl,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,4);	
		//~ 
		//~ sizer.fit(mFrame);
		//~ sizer.setSizeHints(mFrame);
		//~ mFrame.sizer = sizer;
	}
	
	function close (_)
	{
		for (m in Manga.manager.all())
		{
			m.update();
		}
		Manager.cleanup();
		App.quit();
	}
	
	public function throwError(e:String)
	{
		
	}
}
