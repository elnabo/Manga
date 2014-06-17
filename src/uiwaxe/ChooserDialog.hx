package uiwaxe;

import db.Manga;

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
		
		var initNames = Manga.manager.all().filter(function(x:Manga):Bool { return x.lastChapterDownloaded > 0;});
		var names = Lambda.array(Lambda.map(initNames, function (x:Manga):String {return x.rawName;}));
		
		var mangaList = Choice.create(this,null,{x:22,y:20},{width:inSize.width-50,height:20},names);
		mangaList.selection = mangaList.find_string(viewer._manga);
		mangaList.setHandler(wx.EventID.SET_FOCUS, function (e:Dynamic) 
			{
				mangaList.clear();
				mangaList.label = "Select a manga";
				for (manga in Manga.manager.all())
				{
					if (manga.lastChapterDownloaded > 0)
						mangaList.append(manga.rawName);
				}
				mangaList.selection = mangaList.find_string(viewer._manga);
				e.skip = true;
			});
			
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
		
		chapterList.selection = chapterList.find_string(StringTools.lpad(""+viewer._chap,"0",4));
		chapterList.setHandler(wx.EventID.SET_FOCUS, function (e:Dynamic) 
			{
				if (mangaList.value == "Select a manga")
				{
					return;
				}
				
				fromChapter.value = true;
					
				chapterList.clear();
				chapterList.label = "Select a chapter";
				var manga = Manga.get(mangaList.value);
				if (manga == null || manga.lastChapterDownloaded == 0)
				{					
					return;
				}
					
				for (chapter in manga.getChapterList())
				{
					chapterList.append(chapter);
				}
				chapterList.selection = chapterList.find_string(StringTools.lpad(""+viewer._chap,"0",4));
				e.skip = true;
			});
		
			
		var validate = Button.create(this,null, "Validate",{x:45,y:130},{width:100,height:30},null);
		validate.onClick = function(_)
			{
				if (fromChapter.value)
				{
					if (chapterList.value == "Select a chapter")
						return;
		
					viewer.display(mangaList.value,Std.parseInt(unLPad(chapterList.value)), 1);
				}
				else
				{
					if (mangaList.value == "Select a manga")
						return;
						
					var manga = Manga.get(mangaList.value);
					viewer.display(mangaList.value,manga.currentChapterRead,manga.currentPageRead);
				}
				close();
			}
		var cancel = Button.create(this,null, "Cancel",{x:155,y:130},{width:100,height:30},null);
		cancel.onClick = function(_)
			{
				close();
			};
	}
	
	public function unLPad( s : String, p : String = "0" ) : String 
	{
		var l = s.length;
		var r = 0;
		while( r < l && s.charAt(r) == p )
		{
			r++;
		}
		if( r > 0 )
			return s.substr(r, l-r);
		else
			return s;
	}
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
