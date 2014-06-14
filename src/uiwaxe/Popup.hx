package uiwaxe;

import wx.Alignment;
import wx.Button;
import wx.Dialog;
import wx.Loader;
import wx.StaticText;
import wx.Window;

class Popup extends Dialog
{
	public function new (inParent:Window, inID:Null<Int>,inTitle:String="",
						inContent:String="",
						?inPosition:{x:Float,y:Float},
						?inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
		
		StaticText.create(this,null,inContent,{x:0,y:20},{width:inSize.width,height:inSize.height - 90},Alignment.wxALIGN_CENTER);
		
		var ok = Button.create(this,null, "OK",{x:Std.int(inSize.width/2 - 25),y:inSize.height - 65},{width:50,height:30},null);
		ok.onClick = function(_)
			{
				close();
			};	
		
	}
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
