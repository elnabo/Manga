package uiwaxe;

import db.Manga;
import web.Download;
import sys.db.Manager;

import wx.App;
import wx.CommandEvent;
import wx.Dialog;
import wx.Event;
import wx.EventID;
import wx.Frame;
import wx.Menu;
import wx.MenuBar;
import wx.Window;

class UIMain
{
	public static var downloadFinishedEvent(default,null):Int = EventType.newEventType();
	var imgViewer:ImageViewer;
	var mFrame:Frame;
	
	public function new()
	{
		mFrame = Frame.create(null, null, "Manga", null, { width: 800, height: 600 });	
		
		App.setTopWindow(mFrame);
		mFrame.shown = true;
		mFrame.onClose = close;
		
		Download.onFinish = function(e:Manga)
			{
				var content = "You finished downloading " + e.name + 
						".\nLast chapter : " + e.lastChapterDownloaded;
						
				var evt = CommandEvent.create(downloadFinishedEvent);
				evt.string = content;
				Event.queueEvent(mFrame,evt);
			}
			
		mFrame.customHandler(downloadFinishedEvent, 
			function(e:Dynamic)
			{
				new Popup(mFrame,null,"Download finished",e.string,{width:300,height:150});
			});
			
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
		
		var status = new Menu("");
		status.append(id,"Downloads", "Check your downloads");
		mFrame.handle(id++, function (_) 
			{
				new DownloadStatusDialog(mFrame,null,"Downloads status",{width:300, height:200});
			});
		menu.append(status,"Status");
		
		mFrame.menuBar = menu;
		
		imgViewer = new ImageViewer(mFrame,null,{x:0,y:0},null);
		
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
