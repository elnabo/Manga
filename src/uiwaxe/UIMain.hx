package uiwaxe;

import wx.App;
import wx.Frame;

class UIMain
{
	var mFrame:Frame;
	
	public function new()
	{
		var mFrame = Frame.create(null, null, "Manga", null, { width: 800, height: 600 });	
		var imgViewer = new ImageViewer(mFrame);
		
		App.setTopWindow(mFrame);
		mFrame.shown = true;
	}
}
