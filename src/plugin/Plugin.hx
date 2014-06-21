package plugin;

import haxe.Http;
import sys.FileSystem;

class Plugin
{
	public static var mainURL(default,null):String;
	
	private var _manga:String;
	
	public var manga(get,set):String;
	private inline function get_manga(){return _manga;}
	private function set_manga(value:String) {_manga = StringTools.trim(value); findLastChapterLocal(); return _manga;}
	
	public var lastChapter(default,null):Int;
	
	public function new(?manga:String=null)
	{
		if (manga != null && manga!="")
		{
			this.manga = StringTools.trim(manga);
			findLastChapterLocal();
		}
	}
	
	private function findLastChapterLocal():Void
	{		
		if (!FileSystem.exists(manga) || !FileSystem.isDirectory(manga))
		{
			lastChapter = 0;
			return ;
		}
			
		
		
		var subFolder = FileSystem.readDirectory(manga);
		
		if (subFolder == null)
		{
			lastChapter = 0;
			return;
		}
		var sorted = subFolder.filter(
				function(v:String):Bool
				{
					return (Std.parseInt(v)!=null && FileSystem.isDirectory(manga+"/"+v));								
				});
		if (sorted.length == 0)
		{
			lastChapter = 0;
			return;
		}
		var intArray = sorted.map(function(v:String):Int {return Std.parseInt(v);});
		intArray.sort(
					function(a:Int,b:Int){
					if (a < b) {return -1;}
					if (a == b) {return 0;}
					return 1;});
		lastChapter = intArray[0];
		
	}
	
	public function doesChapterExists(chap:Int):Bool {throw "not implemented"; return false;}
	public function exists():Bool {throw "not implemented"; return false;}
	public function getImageURL(chap:Int, page:Int):String {throw "not implemented"; return null;}
}
