package plugin;

import haxe.Http;
import sys.FileSystem;

class MangaReaderPlugin
{
	public static var mainURL(default,null):String = "http://www.mangareader.net/";
	private static var imgRegex:EReg = new EReg("<img.*?\"(http.*?)\"","");
	
	private var _manga:String;
	
	public var manga(get,set):String;
	private inline function get_manga(){return _manga;}
	private inline function set_manga(value:String) {_manga = value; return _manga;}
	
	public var lastChapter(default,null):Int;
	
	public function new(?manga:String=null)
	{
		if (manga != null && manga!="")
		{
			_manga = manga;
			findLastChapterLocal();
		}
	}
	
	private function findLastChapterLocal():Void
	{		
		if (!FileSystem.exists(manga) || !FileSystem.isDirectory(manga))
			return ;
			
		
		var subFolder = FileSystem.readDirectory(manga);
		var sorted = subFolder.filter(
				function(v:String):Bool
				{
					return (Std.parseInt(v)!=null && FileSystem.isDirectory(manga+"/"+v));								
				});
		var intArray = sorted.map(function(v:String):Int {return Std.parseInt(v);});
		intArray.sort(
					function(a:Int,b:Int){
					if (a < b) {return -1;}
					if (a == b) {return 0;}
					return 1;});
					
		lastChapter = intArray.pop();
		
	}
	
	public function getImageURL(chap:Int, page:Int):String
	{
		var url:String = mainURL + manga + "/" + chap + "/" + page;
		var doc:String = Http.requestUrl(url);
		if (doc.indexOf("<h1>404 Not Found</h1>",doc.length-25) != -1)
			throw "http 404";
		imgRegex.match(doc);
		return imgRegex.matched(1);
	}
	
	public function doesChapterExists(chap:Int):Bool
	{
		try
		{
			var doc:String = Http.requestUrl(mainURL+manga+"/"+(chap+1)+"/2");
			return (doc.indexOf("<h1>404 Not Found</h1>",doc.length-25) == -1);
		}
		catch ( _ : Dynamic)
		{
			return false;
		}
	}
}
