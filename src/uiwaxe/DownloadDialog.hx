package uiwaxe;

import web.Download;

import wx.Alignment;
import wx.Button;
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
		
		txtInput = TextCtrl.create(this,null,null,{x:22,y:25},{width:inSize.width - 50, height:30},null);
		txtButton = Button.create(this,null, "Download",{x:47,y:80},{width:inSize.width - 100,height:30},null);
		
		txtError = StaticText.create(this,null,null,{x:0,y:125},{width:inSize.width,height:40},Alignment.wxALIGN_CENTER);
		txtError.setForegroundColor(255,0,0,255);
		txtError.setFontSize(14);
		
		txtButton.onClick = function (_)
			{
				try
				{
					Download.test(txtInput.value);
				}
				catch (e:String)
				{
					switch(e)
					{
						//~ case Error.tooManyActiveConnections:
							//~ txtError.position = {x:0,y:115};
							//~ txtError.label = "Too many downloads. \nTry again later.";
						case Error.invalidName:
							txtError.label = "Invalid name";
						case Error.notAvailable:
							txtError.label = "The manga is not available";
						case _:
							txtError.label = "An unknown error occurred";
					}
					return;
				}
				
				Download.threadedDownload(txtInput.value);
				
				
				close();
			};
			
	}
	
   static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
