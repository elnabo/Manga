package ui;

import db.Manga;

import sys.FileSystem;

import haxe.ui.toolkit.core.DisplayObjectContainer;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Image;
import haxe.ui.toolkit.style.Style;

import flash.events.MouseEvent;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class ImageViewer extends VBox
{
	var _img:Image = new Image();
	var _manga:String;
	var _mangaDB:Manga;
	var _chap:Int = -1;
	var _page:Int = -1;
	
	var _mouseDown = false;
	var _lastMouseX:Int = -1;
	var _lastMouseY:Int = -1;
	var _changingPage:Bool = false;
	
	var _windowWidth = flash.Lib.current.stage.stageWidth;
	var _windowHeight = flash.Lib.current.stage.stageHeight;
	
	var _fullImage:BitmapData;
	var _scaledImage:BitmapData;
	var _imgStartX:Int = 0;
	var _imgStartY:Int = 0;
	var _currentScale:Float = 1;
	
	public function new()
	{
		super();
		
		_img.addEventListener(MouseEvent.MOUSE_WHEEL, function(e)
			{
				_currentScale = clamp(_currentScale + e.delta/20, 1, 2);
				_scaledImage = zoom(_currentScale);
				scroll(0,0);
			});
			
		_img.addEventListener(MouseEvent.MOUSE_DOWN, function(e)
			{
				_changingPage = true;
				_lastMouseX = Std.int(e.localX);
				_lastMouseY = Std.int(e.localY);
			});
			
		_img.addEventListener(MouseEvent.MOUSE_UP, function(e)
			{
				if (_changingPage)
					displayNextPage();
				_changingPage = false;
			});
			
		_img.addEventListener(MouseEvent.MOUSE_MOVE, function(e)
			{
				if (e.buttonDown && _img!=null && _img.resource != null)
				{
					_changingPage = false;
					var dx = Std.int((e.localX - _lastMouseX)/_currentScale);
					var dy = Std.int((e.localY - _lastMouseY)/_currentScale);
					scroll(-1*dx,-1*dy);
				}
				
				_lastMouseX = Std.int(e.localX);
				_lastMouseY = Std.int(e.localY);
			});
		
			
		addChild(_img);
	}
	
	public function display(manga:String,chap:Int,page:Int)
	{
		var path = manga+"/"+StringTools.lpad(""+chap,"0",4)+"/"+StringTools.lpad(""+page,"0",3)+".jpg";
		if (FileSystem.exists(path))
		{
			_fullImage = BitmapData.load(path);
			_scaledImage = _fullImage.clone();
			_img.resource = get(new Rectangle(0,0,width,height));
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
				_mangaDB.currentChapterRead = _chap;
				_mangaDB.currentPageRead = _page;
			}
		}
	}
	
	private function displayPreviousPage(manga:String,chap:Int, page:Int)
	{
		if (_chap <= 1 && _page <= 1)
			return;
			
		if (_page <= 1)
		{
			display(_manga,_chap-1,25);
			return;
		}
		
		display(_manga,_chap,_page-1);		
	}
	
	private function displayNextPage()
	{
		if (FileSystem.exists(_manga+"/"+StringTools.lpad(""+_chap,"0",4)+"/"+StringTools.lpad(""+(_page+1),"0",3)+".jpg"))
		{
			display(_manga,_chap,_page+1);
			return;
		}
		else
		{
			display(_manga,_chap+1,1);
			return;
		}
	}
	
	private function get(rec:Rectangle):BitmapData
	{
		var newRecW = Math.min(rec.width, _scaledImage.width);
		var newRecH = Math.min(rec.height,_scaledImage.height);
		var newRecX = rec.x;
		var newRecY = rec.y;
		if (rec.x + newRecW > _scaledImage.width)
			newRecX = Std.int(Math.max(0,_scaledImage.width - newRecW));
		
		if (rec.y + newRecH > _scaledImage.height)
			newRecY = Std.int(Math.max(0,_scaledImage.height - newRecH));
		rec = new Rectangle(newRecX,newRecY,newRecW,newRecH);
		
		var res = new BitmapData(Std.int(rec.width), Std.int(rec.height));
		if ( Math.abs(_currentScale - 1) < 0.01)
		{
			res.copyPixels(_fullImage,rec,new Point());
		}
		else
		{
			res.copyPixels(_scaledImage,rec,new Point());
		}
		return res;
	}
	
	private function scroll(dx:Int, dy:Int):Void
	{
		
		if (_scaledImage.width <= width)
			_imgStartX = 0;
		else
			_imgStartX = Std.int(clamp(_imgStartX+dx, 0, (_scaledImage.width-width)/_currentScale));
			
		if (_scaledImage.height <= height)
			_imgStartY = 0;
		else
			_imgStartY = Std.int(clamp(_imgStartY+dy, 0, (_scaledImage.height-height)/_currentScale));
			
		_img.resource = get(new Rectangle(Math.floor(_imgStartX*_currentScale),Math.floor(_imgStartY*_currentScale),width,height));
	}
	
	private function clamp(value:Float, min:Float, max:Float):Float
	{
		if (value - min < 0)
			return min;
		if (value - max > 0)
			return max;
		return value;
	}
	
	private function zoom(scale:Float):BitmapData
	{
		var data:BitmapData = new BitmapData(Std.int(_fullImage.width*scale), Std.int(_fullImage.height*scale), true);
		var matrix:Matrix = new Matrix();
		matrix.scale(scale, scale);
		data.draw(_fullImage,matrix);
		return data;
	}
}


