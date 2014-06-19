package plugin;

import haxe.Http;

class MangaReaderPlugin extends Plugin
{
	public static var mainURL(default,null):String = "http://www.mangareader.net/";
	override private function set_manga(value:String):String
	{
		return super.set_manga(StringTools.trim(value).toLowerCase().split(" ").join("-"));
	}
	private static var imgRegex:EReg = new EReg("<img.*?\"(http.*?)\"","");
	
	public function new(?manga:String=null)
	{
		super(manga);
	}
	
	override public function getImageURL(chap:Int, page:Int):String
	{
		var url:String = mainURL + manga + "/" + chap + "/" + page;
		var doc:String = Http.requestUrl(url);
		if (doc.indexOf("<h1>404 Not Found</h1>",doc.length-25) != -1)
			throw "http 404";
		imgRegex.match(doc);
		return imgRegex.matched(1);
	}
	
	override public function doesChapterExists(chap:Int):Bool
	{
		try
		{
			var doc:String = Http.requestUrl(mainURL+manga+"/"+chap);
			return (doc.indexOf("is not published yet") == -1);
		}
		catch ( _ : Dynamic)
		{
			return false;
		}
	}
	
	
	override public function exists():Bool
	{
		var h = new Http(mainURL+manga);
		var exist = true;
		h.onError = function(e:Dynamic) 
			{
				exist = !(e == "Http Error #404");
			};
		h.request(null);
		return exist;
	}
}
