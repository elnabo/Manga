package uiwaxe;

import db.Manga;

import haxe.ds.StringMap;

import wx.Alignment;
import wx.Button;
import wx.Choice;
import wx.Dialog;
import wx.EventID;
import wx.Loader;
import wx.StaticText;
import wx.TextCtrl;
import wx.Window;

class MangaStatusDialog extends Dialog
{
	
	public function new (inParent:Window, inID:Null<Int>, inTitle:String="",
						?inPosition:{x:Float,y:Float},
                   inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
		
		
		var mangas = Manga.all();
		var names:Array<String> = [];
		var rawToManga = new StringMap<Manga>();
		
		for (m in mangas)
		{
			names.push(m.rawName);
			rawToManga.set(m.rawName, m);
		}
		names.sort(function(a,b) return Reflect.compare(a.toLowerCase(),b.toLowerCase())); 
		
		var choice = Choice.create(this,null,{x:22,y:5},{width:inSize.width-50,height:30},names);
		choice.selection = 0;
		
		var rename = TextCtrl.create(this,null,choice.value,{x:22,y:50},{width:inSize.width-120, height:20},null);
		var renameButton = Button.create(this,null, "Rename",{x:inSize.width-90,y:45},{width:60,height:30},null);	
		
		var pluginList = Main.plugins.copy();
		pluginList.push("Unavailable plugin");
		var plugin = Choice.create(this,null,{x:22,y:90},{width:inSize.width-120,height:30},pluginList);
		var s = Main.importPlugins.indexOf(rawToManga.get(names[0]).pluginName);
		plugin.selection = 	(s == -1) ? pluginList.length -1 : s;
		
		var changeButton = Button.create(this,null, "Change",{x:inSize.width-90,y:85},{width:60,height:30},null);	
		changeButton.onClick = function (_)
		{
			rawToManga.get(choice.value).pluginName = Main.importPlugins[plugin.selection];
		};
		
		var deleteButton = Button.create(this,null, "Delete manga",{x:22,y:120},{width:100,height:30},null);		
		var confirmDelete = Button.create(this,null, "Confirm deletion", {x:160,y:120}, {width:100,height:30},null);
		confirmDelete.show(false);
		
		choice.setHandler(wx.EventID.CHOICE, function (e:Dynamic)
		{
			rename.value = e.string;
			confirmDelete.show(false);
			
			var n = rawToManga.get(e.string).pluginName;
			var s = Main.importPlugins.indexOf(n);			
			plugin.selection = (s == -1) ? pluginList.length -1 : s;
		});
		
		renameButton.onClick = function (_)
		{
			var m = rawToManga.get(choice.value);
			m.rename(rename.value);
			choice.set_string(choice.selection, m.rawName);
		}
		
		deleteButton.onClick = function (_)
		{
			confirmDelete.show(true);
		}
		
		confirmDelete.onClick = function (_)
		{
			var m = rawToManga.get(choice.value);
			m.remove();
		}
		
		
		
		//~ var ok = Button.create(this,null, "OK",{x:Std.int(inSize.width/2 - 25),y:inSize.height - 65},{width:50,height:30},null);
		//~ ok.onClick = function(_)
			//~ {
				//~ close();
			//~ };	
	}
	
   static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
