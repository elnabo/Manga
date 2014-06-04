package ui;

import sys.FileSystem;

import haxe.ui.toolkit.core.DisplayObjectContainer;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Image;
import haxe.ui.toolkit.style.Style;

import flash.events.MouseEvent;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class ImageViewer extends VBox
{
	var _img:Image = new Image();
	var _manga:String;
	var _chap:Int;
	var _page:Int;
	
	var _mouseDown = false;
	var _lastMouseX:Int;
	var _lastMouseY:Int;
	var _changingPage:Bool = false;
	
	var _windowWidth = flash.Lib.current.stage.stageWidth;
	var _windowHeight = flash.Lib.current.stage.stageHeight;
	
	var _fullImage:BitmapData;
	var _imgStartX:Int = 0;
	var _imgStartY:Int = 0;
	
	var _currentDX:Int = 0;
	var _currentDY:Int = 0;
	
	
	public function new()
	{
		super();
		
		_img.styleName = "imgViewer";
		//~ if (style == null)
			//~ style = new Style();
		//~ style.width = 500;
		//~ style.height = 400;
		//~ applyStyle();
		//~ _img.style = style;
		//~ _img.applyStyle();
		
		_img.addEventListener(MouseEvent.MOUSE_DOWN, function(e)
			{
				trace(width);
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
					//~ _img.x -= _lastMouseX - Std.int(e.localX);
					//~ _img.y -= _lastMouseY - Std.int(e.localY);
					//~ _img.resource.scroll( -1*_lastMouseX + Std.int(e.localX),-1*_lastMouseY + Std.int(e.localY));
					var dx = Std.int(e.localX) - _lastMouseX;
					var dy = Std.int(e.localY) - _lastMouseY;
					
					// Scrolling left
					if (dx < 0)
					{
						trace("scrolling left");
						// Going outside of the image at the right part of the screen
						if (Math.abs(_currentDX + dx) + style.width > _img.width )
						{
							trace("outside left");
							trace(Math.abs(_currentDX + dx) + style.width);
							var temp = Std.int(_img.width - style.width) - _currentDX;
							trace("currentDx " +_currentDX+ " old " +dx+ " new "+temp);
							dx = Std.int(_img.width - style.width) - _currentDX;
						}
					}
					else if (dx > 0)
					{}
					
					dy = 0;
					
					/*
					if ((dx < 0) && (_currentDX  + dx < 0))
					{
						if (_currentDX == 0)
							dx = 0;
						else
						{
							trace(dx,_currentDX,  "first");
							dx = -1*_currentDX;
						}
					}
					else if ((dx > 0) &&( _currentDX + dx > _img.width - style.width))
					{
						//~ trace( dx, _currentDX - Std.int(_img.width  - style.width), "second");
						trace(dx,_currentDX,_img.width, style.width);
						dx = _currentDX - Std.int(_img.width  - style.width);
					}
					
					if ((dy < 0) && (_currentDY  + dy < 0))
					{
						if (_currentDY == 0)
							dy = -1*_currentDY;
						else
							dy = 0;
					}
					else if ((dy > 0) &&( _currentDY + dy > _img.height - style.height))
						dy = _currentDY - Std.int(_img.height  - style.height);
					*/
							
					//~ _currentDX += dx;
					//~ _currentDY += dy;
					//~ if (dx < 0)
						//~ _imgStartX = Std.int(Math.max(0 ,_imgStartX+dx));
					//~ else if (dx > 0)
						//~ _imgStartX = Std.int(Math.min(style.width - _img.width ,_imgStartX+dx));
						//~ 
					//~ if (dy < 0)
						//~ _imgStartY = Std.int(Math.max(0 ,_imgStartY+dy));
					//~ else if (dy > 0)
						//~ _imgStartY = Std.int(Math.min(style.height - _img.height ,_imgStartY+dy));
					scroll(_img.resource,dx,dy);
				}
				
				_lastMouseX = Std.int(e.localX);
				_lastMouseY = Std.int(e.localY);
			});
		
			
		//~ addChild(_img);
	}
	
	public function display(manga:String,chap:Int,page:Int)
	{
		var path = manga+"/"+StringTools.lpad(""+chap,"0",4)+"/"+StringTools.lpad(""+page,"0",3)+".jpg";
		if (FileSystem.exists(path))
		{
			//~ _fullImage = BitmapData.load(path);
			_img.resource = BitmapData.load(path);
			_manga = manga;
			_chap = chap;
			_page = page;
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
	
	private function scroll(src:BitmapData, dx:Int, dy:Int):Void
	{
		_currentDX += dx;
		_currentDY += dy;
		trace(_currentDX, _currentDY);
		
		/*
		var rect = src.rect;
		if (dx > 0)
		{
			if (rect.right+dx > src.width)
				dx = Std.int(src.width - rect.right);
		}
		else if (dx < 0)
		{
			if (rect.left + dx < 0)
				dx = -1*Std.int(rect.left);
		}
		
		if (dy > 0)
		{
			if (rect.bottom+dy > src.height)
				dy = Std.int(src.height - rect.bottom);
		}
		else if (dy < 0)
		{
			if (rect.top + dy < 0)
				dy = -1*Std.int(rect.top);
		}
		*/
		src.scroll(dx,dy);
	}
	
	private static function resizeBitmapData(src:BitmapData, width:Int, height:Int):BitmapData
	{
		var scaleX:Float = width / src.width;
		var scaleY:Float = height / src.height;
		var data:BitmapData = new BitmapData(width, height, true);
		var matrix:Matrix = new Matrix();
		matrix.scale(scaleX, scaleY);
		data.draw(src,matrix);
		return data;
	}
}


