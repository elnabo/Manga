package uiwaxe;

import wx.Dialog;
import wx.Loader;
import wx.Window;

class ExportDialog extends Dialog
{
	public function new (inParent:Window, inID:Null<Int>, inTitle:String="",
						?inPosition:{x:Float,y:Float},
                   inSize:{width:Int,height:Int})
	{
		var handle = wx_dialog_create([inParent==null ? null : inParent.wxHandle,inID,inTitle,inPosition,inSize, Dialog.DEFAULT_STYLE| Window.STAY_ON_TOP] );
		super(handle);
		
		inParent.disable();
		onClose = function(_) { inParent.enable(); destroy();}
	}
	
	static var wx_dialog_create:Array<Dynamic>->Dynamic = Loader.load("wx_dialog_create",1);
}
