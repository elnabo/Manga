package uiwaxe;

import db.Manga;
import web.Download;

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

class UIMain
{
	public static var downloadFinishedEvent(default,null):Int = EventType.newEventType();
	public static var onClose:Void->Void;
	var imgViewer:ImageViewer;
	var mFrame:Frame;
	public static var manga:Menu;
	public static var rotateId:Int;
	
	public function new()
	{
		mFrame = Frame.create(null, null, "Manga", null, { width: 800, height: 600 });	
		
		App.setTopWindow(mFrame);
		mFrame.shown = true;
		mFrame.onClose = close;
		
		Download.onFinish = function(e:Manga, b:Bool)
			{
				var content = "You finished downloading " + e.rawName + 
						".\nLast chapter : " + e.lastChapterDownloaded;
						
				var evt = CommandEvent.create(downloadFinishedEvent);
				evt.string = content;
				evt.int = (b) ? 1 : 0;
				wx.App.wakeUpIdle();
				Event.queueEvent(mFrame,evt);
			}
			
		mFrame.customHandler(downloadFinishedEvent, 
			function(e:Dynamic)
			{
				wx.App.wakeUpIdle();
				if (e.int == 1)
				{
					new Popup(mFrame,null,"Download finished",e.string,{width:300,height:200});
				}
				
				var mangas = Lambda.array(Manga.all().filter(
					function(e:Manga) { return e.downloadStatus == 2;}));
					
				if (mangas.length == 0)
					return;
					
				mangas.sort(
					function (e1:Manga, e2:Manga) { if (e1.downloadPriority > e2.downloadPriority) return -1;
													if (e1.downloadPriority == e2.downloadPriority) return 0;
													return 1;});
				
				if ( mangas[0].pluginName != "None")
					Download.threadedDownload(mangas[0].rawName, mangas[0].pluginName);
				
			});
			
		//~ mFrame.setHandler(EventID.ICONIZE,
			//~ function(e:Dynamic)
			//~ {
				//~ //Do not pause
			//~ });
			
			
		mFrame.setHandler(EventID.IDLE,
			function(e:Dynamic)
			{
				if (mFrame.isIconized() || !mFrame.isActive())
				{
					Sys.sleep(0.1);
					wx.App.wakeUpIdle();
				}
			});
			
		var menu = new MenuBar();
		var id = 0;
		
		var file = new Menu("");
			
		file.append(id,"Exit","Exit the application");
		mFrame.handle(id++, close);
		menu.append(file,"File");
		
		manga = new Menu("");
		manga.append(id,"Download", "Download a manga");
		mFrame.handle(id++, function (_) 
			{
				new DownloadDialog(mFrame,null,"Download a manga",{width:300,height:275});
			});
		manga.append(id,"Read a manga", "");
		mFrame.handle(id++, function (_) 
			{
				new ChooserDialog(imgViewer,mFrame,null,"Choose a manga",{width:300,height:200});
			});
		manga.append(id,"Rotate image","");
		manga.enable(id,false);
		rotateId = id;
		mFrame.handle(id++,function (_)
			{
				imgViewer.rotate();
			});
		menu.append(manga,"Manga");
		
		var convert = new Menu("");
		convert.append(id,"Export", "Export a manga");
		mFrame.handle(id++, function (_) 
			{
				new ExportDialog(mFrame,null,"Export a manga",{width:300,height:220});
			});
		convert.append(id,"Import", "Import a manga");
		mFrame.handle(id++, function (_) 
			{
				new ImportDialog(mFrame,null,"Import a manga",{width:300,height:220});
			});
		menu.append(convert,"Convert");
		
		var status = new Menu("");
		status.append(id,"Downloads", "Check your downloads");
		mFrame.handle(id++, function (_) 
			{
				new DownloadStatusDialog(mFrame,null,"Downloads status",{width:300, height:200});
			});
		status.append(id,"Mangas", "Check your mangas");
		mFrame.handle(id++, function (_) 
			{
				new MangaStatusDialog(mFrame,null,"Manga status",{width:300, height:200});
			});
		menu.append(status,"Status");
		
		mFrame.menuBar = menu;
		
		imgViewer = new ImageViewer(mFrame,null,{x:0,y:0},null);
		
		var ico = Icon.createFromBytes(haxe.Resource.getBytes("logo"));		
		mFrame.setIcon(ico);
		
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
