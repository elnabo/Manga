package uiwaxe;

import db.Manga;
import sys.db.Manager;

import wx.App;
import wx.Dialog;
import wx.EventID;
import wx.Frame;
import wx.Menu;
import wx.MenuBar;
import wx.Window;

class UIMain
{
	var imgViewer:ImageViewer;
	var mFrame:Frame;
	
	public function new()
	{
		mFrame = Frame.create(null, null, "Manga", null, { width: 800, height: 600 });	
		imgViewer = new ImageViewer(mFrame,null,{x:0,y:0}, {width:800,height:600});
		
		App.setTopWindow(mFrame);
		mFrame.shown = true;
		mFrame.onClose = close;
			
		var menu = new MenuBar();
		var id = 0;
		
		var file = new Menu("");
		
		file.append(id,"Exit","Exit the application");
		mFrame.handle(id++, close);
		menu.append(file,"File");
		
		var manga = new Menu("");
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
		
		var convert = new Menu("");
		convert.append(id,"Import", "Import a manga");
		mFrame.handle(id++, function (_) {} );
		menu.append(convert,"Convert");
		
		mFrame.menuBar = menu;
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
