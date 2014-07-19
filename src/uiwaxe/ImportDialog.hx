package uiwaxe;

import conversion.Import;
import db.Manga;
import utils.Utility;

import sys.FileSystem;

import wx.Alignment;
import wx.Button;
import wx.CheckBox;
import wx.Choice;
import wx.Dialog;
import wx.FileDialog;
import wx.Loader;
import wx.StaticText;
import wx.TextCtrl;
import wx.Window;

class ImportDialog extends Dialog
{
	var directory:String = Main.mangaPath;
	
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
				
		var chooser = Button.create(this,null, "Choose a cbz",{x:20,y:15},{width:100,height:30},null);
		var fileName = StaticText.create(this,null,"",{x:130,y:20},{width:100,height:20},Alignment.wxALIGN_LEFT);
		var mangaInput = TextCtrl.create(this,null,null,{x:22,y:60},{width:150, height:20},null);
		var chapterInput = TextCtrl.create(this,null,null,{x:175,y:60},{width:100, height:20},null);
		
		chooser.onClick = function(_)
			{
				var e = new FileDialog(null, "Choose a cbz",Main.exportPath,"","CBZ files (*.cbz)|*.cbz|ZIP files (*.zip)|*.zip",FileDialog.OPEN);
				e.showModal();
				
				directory = e.directory;
				var f = e.files[0];
				fileName.label = f;
				
				var noExt = f.split(".")[0];
				if (noExt.indexOf("_") == -1)
				{
					var intValue = Std.parseInt(Utility.unLPad(noExt));
					if (intValue != null)
						chapterInput.value = ""+intValue;
					else
					{
						var manga = Manga.get(noExt);
						if (manga != null)
							mangaInput.value = manga.rawName;
					}
				}
				else
				{
					var s = noExt.split("_");
					var intValue = Std.parseInt(Utility.unLPad(s.pop()));
					if (intValue != null)
						chapterInput.value = ""+intValue;
					var manga = Manga.get(s.join("_"));
					if (manga != null)
						mangaInput.value = manga.rawName;
				}
			}
		
		var validate = Button.create(this,null, "Validate",{x:45,y:85},{width:100,height:30},null);
		validate.onClick = function(_)
			{
				
				Import.threadedFromCBZ(directory+"/"+fileName.label, mangaInput.value, Std.parseInt(chapterInput.value));
				close();
			}
		
		var cancel = Button.create(this,null, "Cancel",{x:155,y:85},{width:100,height:30},null);
		cancel.onClick = function(_)
			{
				close();
			};
	}
	
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
