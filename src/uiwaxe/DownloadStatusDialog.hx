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

class DownloadStatusDialog extends Dialog
{
	
	public function new (inParent:Window, inID:Null<Int>, inTitle:String="",
						?inPosition:{x:Float,y:Float},
                   inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP ] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
		
		StaticText.create(this,null,"Downloading",{x:0,y:20},{width:inSize.width,height:20},Alignment.wxALIGN_CENTER);
		StaticText.create(this,null,"Waiting",{x:0,y:80},{width:inSize.width,height:20},Alignment.wxALIGN_CENTER);
		
		var mangas = Manga.sorted();
		
		var download = Choice.create(this,null,{x:22,y:50},{width:inSize.width-50,height:20},
				Lambda.array(mangas.filter(function(e:Manga) { return e.downloadStatus == 1;}).map(function(e:Manga){return e.rawName;})));
		download.selection = 0;
		var wait = Choice.create(this,null,{x:22,y:110},{width:inSize.width-50,height:20},
				Lambda.array(mangas.filter(function(e:Manga) { return e.downloadStatus == 2;}).map(function(e:Manga){return e.rawName;})));
		wait.selection = 0;
	}
	
   static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
