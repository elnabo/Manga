package uiwaxe;

import db.Manga;
import utils.Utility;

import wx.Alignment;
import wx.Button;
import wx.Choice;
import wx.Dialog;
import wx.Loader;
import wx.RadioButton;
import wx.StaticText;
import wx.Window;

class ChooserDialog extends Dialog
{
	public function new (viewer:ImageViewer,inParent:Window, ?inID:Int, inTitle:String="",
						?inPosition:{x:Float,y:Float},
                   ?inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
		
		var initNames = Manga.all().filter(function(x:Manga):Bool { return x.lastChapterDownloaded > 0;});
		var names = Lambda.array(Lambda.map(initNames, function (x:Manga):String {return x.rawName;}));
		
		var mangaList = Choice.create(this,null,{x:22,y:20},{width:inSize.width-50,height:20},names);
		mangaList.selection = mangaList.find_string(viewer._manga);
		
		var lastRead = RadioButton.create(this,null,"Continue from last read",{x:20,y:50},null,RadioButton.wxRB_GROUP);
		var fromChapter = RadioButton.create(this,null,"Go to",{x:20,y:70},null,0);
		
		var chaps:Array<String> = [];
		if (viewer._manga != null)
		{
			var manga = Manga.get(mangaList.value);
			if (manga != null && manga.lastChapterDownloaded != 0)
			{
				chaps = manga.getChapterList();
			}
		}
		var chapterList = Choice.create(this,null,{x:47,y:90},{width:inSize.width-100,height:20},chaps);
		
		
		mangaList.setHandler(wx.EventID.SET_FOCUS, function (e:Dynamic) 
			{
				mangaList.clear();
				mangaList.label = "Select a manga";
				for (manga in Manga.all())
				{
					if (manga.lastChapterDownloaded > 0)
						mangaList.append(((manga.recentDownload == 1) ? "[new] " : "      ") +manga.rawName);
				}
				mangaList.selection = mangaList.find_string(viewer._manga);
				e.skip = true;
				
				chapterList.clear();
			});
			
		
		chapterList.selection = chapterList.find_string(StringTools.lpad(""+viewer._chap,"0",4));
		chapterList.setHandler(wx.EventID.SET_FOCUS, function (e:Dynamic) 
			{
				if (mangaList.value == null)
				{
					return;
				}
				
				fromChapter.value = true;
					
				chapterList.clear();
				chapterList.label = "Select a chapter";
				var manga = Manga.getFromRaw(mangaList.value.substr(6));
				if (manga == null || manga.lastChapterDownloaded == 0)
				{					
					return;
				}
				
				
				var list = manga.getChapterList();
				if (list==null || list.length == 0)
				{
					e.skip = true;
					return;
				}
				manga.currentChapterRead = Std.int(Math.min(manga.currentChapterRead,Std.parseInt(Utility.unLPad(list[0]))));
				for (chapter in list)
				{
					chapterList.append(chapter);
				}
				chapterList.selection = chapterList.find_string(StringTools.lpad(""+viewer._chap,"0",4));
				e.skip = true;
			});
		
			
		var validate = Button.create(this,null, "Validate",{x:45,y:130},{width:100,height:30},null);
		validate.onClick = function(_)
			{
				var manga = Manga.getFromRaw(mangaList.value.substr(6));
				if (manga == null)
					return;
					
				if (fromChapter.value)
				{
					if (chapterList.value == null)
						return;
		
					viewer.display(manga.name,Std.parseInt(Utility.unLPad(chapterList.value)), 1);
				}
				else
				{
					if (mangaList.value == null)
						return;
					
					var chapter = Std.int(Math.max(manga.currentChapterRead,Std.parseInt(Utility.unLPad(manga.getChapterList()[0]))));
					viewer.display(manga.name,chapter,manga.currentPageRead);
				}
				close();
			}
		var cancel = Button.create(this,null, "Cancel",{x:155,y:130},{width:100,height:30},null);
		cancel.onClick = function(_)
			{
				close();
			};
	}
	
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
