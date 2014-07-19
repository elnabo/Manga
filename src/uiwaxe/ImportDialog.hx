package uiwaxe;

import conversion.Export;
import db.Manga;
import utils.Utility;

import sys.FileSystem;

import wx.Alignment;
import wx.Button;
import wx.CheckBox;
import wx.Choice;
import wx.Dialog;
import wx.Loader;
import wx.StaticText;
import wx.Window;

class ImportDialog extends Dialog
{
	public function new (inParent:Window, inID:Null<Int>, inTitle:String="",
						?inPosition:{x:Float,y:Float},
                   inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
		
		var names:Array<String> = new Array<String>();
		for (m in Manga.all())
		{
			if (m.lastChapterDownloaded > 0)
				names.push(m.rawName);
		}
		
		
		var mangaList = Choice.create(this,null,{x:22,y:20},{width:inSize.width-50,height:20},names);
		var checkRotate = CheckBox.create(this,null,"Rotate double page",{x:22,y:50});
		StaticText.create(this,null,"From chapter",{x:22,y:80},{width:100,height:20},Alignment.wxALIGN_LEFT);
		var startChoice = Choice.create(this,null,{x:130,y:80},{width:80,height:20},[]);
		StaticText.create(this,null,"To ",{x:22,y:110},{width:100,height:20},Alignment.wxALIGN_LEFT);
		var endChoice = Choice.create(this,null,{x:130,y:110},{width:80,height:20},[]);
		
		mangaList.setHandler(wx.EventID.CHOICE, function (e:Dynamic)
		{
			var manga = Manga.getFromRaw(e.string);
			var mangaFolder = Main.mangaPath + ((manga==null) ? e.string : manga.name);
			if (!FileSystem.exists(mangaFolder))
				return;
			
			var i = 0;
			startChoice.clear();
			endChoice.clear();
			for (folder in FileSystem.readDirectory(mangaFolder))
			{
				if (FileSystem.isDirectory(mangaFolder+"/"+folder))
				{
					startChoice.append(folder);
					endChoice.append(folder);
					i++;
				}
			}
			startChoice.selection = 0;
			endChoice.selection = i-1;
		});
		
		
		startChoice.setHandler(wx.EventID.CHOICE, function (e:Dynamic)
		{
			if (startChoice.selection > endChoice.selection)
				endChoice.selection = startChoice.selection;
		});
		
		
		endChoice.setHandler(wx.EventID.CHOICE, function (e:Dynamic)
		{
			if (startChoice.selection > endChoice.selection)
				startChoice.selection = endChoice.selection;
		});
		
		var validate = Button.create(this,null, "Validate",{x:45,y:140},{width:100,height:30},null);
		validate.onClick = function(_)
			{
				var manga = Manga.getFromRaw(mangaList.value);
				var mangaFolder = (manga==null) ? mangaList.value : manga.name;
				
				Export.threadedToCBZ(mangaFolder,Std.parseInt(Utility.unLPad(startChoice.value)),
							Std.parseInt(Utility.unLPad(endChoice.value)), checkRotate.checked);
				close();
			}
		
		var cancel = Button.create(this,null, "Cancel",{x:155,y:140},{width:100,height:30},null);
		cancel.onClick = function(_)
			{
				close();
			};
	}
	
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
