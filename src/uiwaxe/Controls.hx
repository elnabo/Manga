package uiwaxe;

import db.Manga;

import web.Download;

import wx.Button;
import wx.ComboBox;
import wx.FlexGridSizer;
import wx.Loader;
import wx.Panel;
import wx.Sizer;
import wx.TextCtrl;
import wx.Window;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Controls extends Panel
{
	var viewer:ImageViewer;
	var txtInput:TextCtrl;
	var txtButton:Button;
	var dropDown:ComboBox;
	
	public function new(viewer:ImageViewer, inParent:Window,?inID:Int,?inPosition:Position,
		?inSize:Size, ?inStyle:Int)
	{
		var handle = wx_window_create([inParent.wxHandle,inID,"",inPosition,inSize, inStyle] );
		super(handle);
			 
		this.viewer = viewer;
		
		var buttonSize = (inSize == null) ? {width:size.width, height:30} : {width:inSize.width, height:20};
		txtInput = TextCtrl.create(this,null,null,null,buttonSize,null);
		txtButton = Button.create(this,null, "Download",{x:0, y:txtInput.size.height},buttonSize,null);
		txtButton.onClick = function (e)
			{
				Thread.create(function(){
				Download.download(txtInput.value);});
			};

		dropDown = ComboBox.create(this,null,"Select a manga",{x:0,y:txtInput.size.height+txtButton.size.height},buttonSize,null, 2);
		dropDown.setHandler(wx.EventID.COMMAND_COMBOBOX_DROPDOWN, function (e:Dynamic) 
			{
				dropDown.clear();
				dropDown.label = "Select a manga";
				for (manga in Manga.manager.all())
				{
					dropDown.append(manga.name);
				}
			});
		dropDown.onSelected = function (e : Dynamic) 
			{ 
				var manga = Manga.get(dropDown.value);
				this.viewer.display(dropDown.value,manga.currentChapterRead,manga.currentPageRead);
			};

		var szr = FlexGridSizer.create(3,1);
		szr.add(txtInput,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,0);
		szr.add(txtButton,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,0);
		szr.add(dropDown,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,0);
		szr.fit(this);
		sizer = szr;
	}
	
	//~ public function initSizer()
	//~ {
		 //~ var szr = FlexGridSizer.create(3,1);
		 //~ szr.add(txtInput,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,0);
		 //~ szr.add(txtButton,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,0);
		 //~ szr.add(dropDown,1,Sizer.EXPAND|Sizer.ALIGN_TOP|Sizer.ALIGN_CENTER_HORIZONTAL,0);
		 //~ szr.fit(this);
		 //~ sizer = szr;
		 //~ return szr;
	//~ }
	
	static var wx_window_create:Array<Dynamic>->Dynamic = Loader.load("wx_window_create",1);
}
