package uiwaxe;

import db.Manga;
import utils.Utility;

import wx.Alignment;
import wx.Button;
import wx.Choice;
import wx.Dialog;
import wx.Loader;
import wx.RadioButton;
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
		
		var names:Array<String> = new Array<String>();
		for (m in Manga.all())
		{
			if (m.lastChapterDownloaded > 0)
				names.push(((m.recentDownload == 1) ? "[new] " : "") +m.rawName);
		}
		
		var mangaList = Choice.create(this,null,{x:22,y:20},{width:inSize.width-50,height:20},names);
		
		var chapterList = Choice.create(this,null,{x:47,y:90},{width:inSize.width-100,height:20},[]);
		if (viewer._manga != null)
		{
			var manga = Manga.get(viewer._manga);
			if (manga != null)
			{
				if (manga.lastChapterDownloaded != 0)
				{
					for (chap in manga.getChapterList())
					{
						chapterList.append(chap);
					}
				}
				
				mangaList.selection = mangaList.find_string(manga.rawName);
				chapterList.selection = chapterList.find_string(StringTools.lpad(""+viewer._chap,"0",4));
			}
		}		
		
		var lastRead = RadioButton.create(this,null,"Continue from last read",{x:20,y:50},null,RadioButton.wxRB_GROUP);
		var fromChapter = RadioButton.create(this,null,"Go to",{x:20,y:70},null,0);
		
		
		
		mangaList.setHandler(wx.EventID.CHOICE, function (e:Dynamic)
			{
				chapterList.clear();
				var manga = Manga.getFromRaw(valueToName(e.string));
				
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
				for (chapter in list)
				{
					chapterList.append(chapter);
				}
				
				var chapSelected = -1;
				if (viewer._manga == manga.rawName)
				{
					chapSelected = viewer._chap;
				}
				else
				{
					chapSelected = Std.int(Math.max(manga.currentChapterRead,Std.parseInt(Utility.unLPad(list[0]))));
				}
				chapterList.selection = chapterList.find_string(StringTools.lpad(""+chapSelected,"0",4));
				
			});
			
			chapterList.setHandler(wx.EventID.CHOICE, function (e:Dynamic)
			{
				fromChapter.value = true;	
			});
			
		var validate = Button.create(this,null, "Validate",{x:45,y:130},{width:100,height:30},null);
		validate.onClick = function(_)
			{
				var manga = Manga.getFromRaw(valueToName(mangaList.value));
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
	
	function valueToName(value:String):String
	{
		if (value.substr(0,5) == "[new]")
		{
			return value.substr(6);
		}
		return value;
	}
	
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
