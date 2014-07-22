package uiwaxe;

import web.Download;

import wx.Alignment;
import wx.Button;
import wx.Choice;
import wx.Dialog;
import wx.Loader;
import wx.StaticText;
import wx.TextCtrl;
import wx.Window;

class DownloadDialog extends Dialog
{
	var txtInput:TextCtrl;
	var txtButton:Button;
	var txtError:StaticText;
	
	public function new (inParent:Window, inID:Null<Int>, inTitle:String="",
						?inPosition:{x:Float,y:Float},
                   inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
		
		txtInput = TextCtrl.create(this,null,null,{x:22,y:25},{width:inSize.width - 50, height:20},null);
		
		StaticText.create(this,null,"From chapter",{x:52,y:60},{width:100,height:20},Alignment.wxALIGN_LEFT);
		var chapInput = TextCtrl.create(this,null,"1",{x:152,y:60},{width:70, height:20},null);
		
		StaticText.create(this,null,"On", {x:52, y:90}, {width:30, height:20},Alignment.wxALIGN_LEFT);
		var pluginChoice = Choice.create(this,null,{x:82,y:85},{width:140,height:25},Main.plugins);
		pluginChoice.selection = 0;
		
		txtButton = Button.create(this,null, "Download",{x:45,y:120},{width:100,height:30},null);		
		
		txtError = StaticText.create(this,null,null,{x:0,y:155},{width:inSize.width,height:40},Alignment.wxALIGN_CENTER);
		txtError.setForegroundColor(255,0,0,255);
		txtError.setFontSize(14);
		
		txtButton.onClick = function (_)
			{
				var chap = Std.parseInt(chapInput.value);
				if ( (chap == null) || (chap == Math.NaN) || (chap < 1) )
				{
					txtError.label = "Invalid chapter number";
					return;
				}
				
				try
				{
					Download.test(txtInput.value, Main.importPlugins[pluginChoice.selection]);
				}
				catch (e:String)
				{
					switch(e)
					{
						case Error.invalidName:
							txtError.label = e;
						case Error.notAvailable:
							txtError.label = e+Main.plugins[pluginChoice.selection];
						case Error.plugin:
							txtError.label = e;
						case _:
							txtError.label = "An unknown error occurred";
					}
					return;
				}
				
				Download.threadedDownload(txtInput.value,Main.importPlugins[pluginChoice.selection], chap);
				
				
				close();
			};
			
		var cancel = Button.create(this,null, "Cancel",{x:155,y:120},{width:100,height:30},null);
		cancel.onClick = function(_)
			{
				close();
			};
			
	}
	
   static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
