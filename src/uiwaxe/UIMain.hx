package uiwaxe;

import db.Manga;
import web.Download;
import sys.db.Manager;

import wx.App;
import wx.Bitmap;
import wx.CommandEvent;
import wx.Dialog;
import wx.Event;
import wx.EventID;
import wx.Frame;
import wx.Icon;
import wx.Menu;
import wx.MenuBar;
import wx.Window;


#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class UIMain
{
	public static var downloadFinishedEvent(default,null):Int = EventType.newEventType();
	public static var onClose:Void->Void;
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
				var mangas = Lambda.array(Manga.manager.all().filter(
					function(e:Manga) { return e.downloadStatus == 2;}));
					
				if (mangas.length == 0)
					return;
					
				mangas.sort(
					function (e1:Manga, e2:Manga) { if (e1.downloadPriority > e2.downloadPriority) return -1;
													if (e1.downloadPriority == e2.downloadPriority) return 0;
													return 1;});
				Thread.create( function()
				{
					Download.download(mangas.pop().rawName);
				
				});
				
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
		
		mFrame.setIcon(Icon.createFromFile("../assets/logo64.ico",WxBitmapType.wxBITMAP_TYPE_ICO));
		
	}
	
	function close (_)
	{
		if (onClose != null)
			onClose();
		App.quit();
	}
	
	public function throwError(e:String)
	{
		
	}
}
