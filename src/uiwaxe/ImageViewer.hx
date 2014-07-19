package uiwaxe;

import db.Manga;

import wx.Bitmap;
import wx.DC;
import wx.EventID;
import wx.Image;
import wx.Loader;
import wx.Panel;
import wx.Window;

import sys.FileSystem;
import sys.io.File;


class ImageViewer extends Panel
{
	public var _manga(default,null):String;
	var _mangaDB:Manga;
	public var _chap(default,null):Int = -1;
	var _page:Int = -1;
	
	var _scaledImage:Image;
	var _fullImage:Image;
	
	var _lastMouseX:Int = -1;
	var _lastMouseY:Int = -1;
	var _changingPage:Bool = false;
	
	var _imgStartX:Int = 0;
	var _imgStartY:Int = 0;
	var _currentScale:Float = 1;
	
	var width:Int;
	var height:Int;
	
	var timestamp:Float = Sys.time();
	
	var needToResize:Bool = false;
	var lastResizeDemande:Float = Sys.time();
	
	var _parent:Window;

	public function new(inParent:Window,?inID:Null<Int>,?inPosition:{x:Int,y:Int},?inStyle:Null<Int>)
	{
		 _parent = inParent;
		 
		 width = _parent.clientSize.width;
		 height = _parent.clientSize.height;
		 
		 var handle = wx_window_create([inParent.wxHandle,inID,"",inPosition,inParent.clientSize, inStyle] );
		 super(handle);
		 onPaint = paintWindow;
		 
		 setHandler(EventID.LEFT_DOWN, function(e:Dynamic):Void 
			{
				_changingPage = true;
				_lastMouseX = e.x;
				_lastMouseY = e.y;
			});
		 setHandler(EventID.LEFT_UP, function(_):Void 
			{
				if (_changingPage)
					displayNextPage();
				_changingPage = false;
			});
		 setHandler(EventID.RIGHT_UP, function(_):Void 
			{
				displayPreviousPage();
			});
		 setHandler(EventID.MOTION, function(e:Dynamic):Void 	
			{
				if (e.leftIsDown)
				{
					_changingPage = false;
					var dx = Std.int((e.x - _lastMouseX)/_currentScale);
					var dy = Std.int((e.y - _lastMouseY)/_currentScale);
					scroll(dx,dy);
				}
				
				_lastMouseX = e.x;
				_lastMouseY = e.y;
			});
		 setHandler(EventID.MOUSEWHEEL, function(e:Dynamic):Void 
			{
				_currentScale = clamp((_currentScale + (e.wheelRotation > 0 ? 1 : -1)/20),0.5,2);
				zoom(_currentScale);
				scroll(0,0);
			});
			
		setHandler(EventID.SIZE,function(e:Dynamic):Void
			{
				width = _parent.clientSize.width;
				height = _parent.clientSize.height;
				size = {width:width, height:height};
					
			});
		
		_fullImage = _scaledImage = Image.getBlankImage(1,1);
		
	}
	
	public function display(manga:String,chap:Int,page:Int)
	{
		var path = Main.mangaPath + manga+"/"+StringTools.lpad(""+chap,"0",4)+"/"+StringTools.lpad(""+page,"0",3)+".jpg";
		if (FileSystem.exists(path))
		{
			_fullImage = Image.fromFile(path,wxBITMAP_TYPE_JPEG);
			_scaledImage = _fullImage;
			_imgStartX = 0;
			_imgStartY = 0;
			_currentScale = 1;
			if (_manga != manga)
			{
				if (_mangaDB != null)
				{
					_mangaDB.update();
				}
				_mangaDB = Manga.get(manga);
			}
			
			_manga = manga;
			if (_chap != chap && _chap != -1)
			{
				_mangaDB.lastChapterRead = _chap;
			}
			_chap = chap;
			_page = page;
			if (_mangaDB != null)
			{
				_mangaDB.recentDownload = 0;
				_mangaDB.currentChapterRead = _chap;
				_mangaDB.currentPageRead = _page;
				_mangaDB.update();
			}
			
			refresh(); 
		}
	}
	
	private function displayPreviousPage()
	{
		if (_chap <= 1 && _page <= 1)
			return;
			
		if (_page <= 1)
		{
			display(_manga,_chap-1,getLastPageNumber(_manga,_chap-1));
			return;
		}
		
		display(_manga,_chap,_page-1);		
	}
	
	private function getLastPageNumber(manga:String, chap:Int)
	{
		var path = Main.mangaPath + manga+"/"+StringTools.lpad(""+chap,"0",4)+"/";
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
			return FileSystem.readDirectory(path).length;
		return -1;
	}
	
	private function displayNextPage()
	{
		if (_manga == null)
			return;
			
		if (FileSystem.exists(Main.mangaPath + _manga+"/"+StringTools.lpad(""+_chap,"0",4)+"/"+StringTools.lpad(""+(_page+1),"0",3)+".jpg"))
		{
			display(_manga,_chap,_page+1);
			return;
		}
		else if (_mangaDB.chapterExists(_chap+1))
		{
			display(_manga,_chap+1,1);
			return;
		}
	}
	
	private function scroll(dx:Int, dy:Int)
	{
		if (_scaledImage.width <= width)
			_imgStartX = 0;
		else
			_imgStartX = Std.int(clamp(_imgStartX + dx, -1*(_scaledImage.width - width), 0));
		
		if (_scaledImage.height <= height)
			_imgStartY = 0;
		else
			_imgStartY = Std.int(clamp(_imgStartY + dy, -1*(_scaledImage.height - height), 0));
		
		refresh();
	}
	
	private function zoom(scale:Float)
	{
		if (_manga == null)
			return;
		if (Math.abs(1-scale) < 0.01)
			_scaledImage = _fullImage;
		else
		{
			_scaledImage = _fullImage.clone();
			_scaledImage.rescale(Std.int(_fullImage.width*scale), Std.int(_fullImage.height*scale), wxIMAGE_QUALITY_NEAREST);
		}
		refresh();
	}
	
	function paintWindow(dc:wx.DC)
	{
		dc.clear();
		if (_scaledImage != null)
			dc.drawBitmap(Bitmap.fromImage(_scaledImage),_imgStartX,_imgStartY, false);
	}
	
	private function clamp(value:Float, min:Float, max:Float):Float
	{
		if (value - min < 0)
			return min;
		if (value - max > 0)
			return max;
		return value;
	}
	
	static var wx_window_create:Array<Dynamic>->Dynamic = Loader.load("wx_window_create",1);
}
