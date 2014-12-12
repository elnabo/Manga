package plugin;

import haxe.Http;

class MangaBirdPlugin extends Plugin
{
	public static var mainURL(default,null):String = "http://www.mangabird.com/";
	override private function set_manga(value:String):String
	{
		return super.set_manga(StringTools.trim(value).toLowerCase().split(" ").join("-"));
	}
	private static var imgRegex:EReg = new EReg("<img.*?\"(http://image.mangabird.*?)\"","");
	
	public function new(?manga:String=null)
	{
		super(manga);
		trace(manga);
	}
	
	override public function getImageURL(chap:Int, page:Int):String
	{
		var url:String = mainURL + manga + "-" + chap + "?page=" + page;
		var doc:String = Http.requestUrl(url);
		if (doc.indexOf("Page not found") != -1)
			throw "Http Error #404";
		
		try
		{
			imgRegex.match(doc);
			return imgRegex.matched(1);
		}
		catch (e:Dynamic)
		{
			throw "Http Error #404";
		}
	}
	
	override public function doesChapterExists(chap:Int):Bool
	{
		try
		{
			var doc:String = Http.requestUrl(mainURL+manga+"-"+chap);
			return (doc.indexOf("Page not found") == -1);
		}
		catch ( _ : Dynamic)
		{
			return false;
		}
	}
	
	
	override public function exists():Bool
	{
		var h = new Http(mainURL+manga+"-1");
		var exist = true;
		h.onError = function(e:Dynamic) 
			{
				exist = !(e == "Http Error #404");
			};
		h.onStatus = function(e:Int) 
			{
				exist = (e == 200);
			};
		h.request(null);
		return exist;
	}
}
