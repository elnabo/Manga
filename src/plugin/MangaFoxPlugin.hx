package plugin;

import haxe.Http;

class MangaFoxPlugin extends Plugin
{
	public static var mainURL(default,null):String = "http://mangafox.me/manga/";
	override private function set_manga(value:String):String
	{
		return super.set_manga(StringTools.trim(value).toLowerCase().split(" ").join("_"));
	}
	private static var imgRegex:EReg = new EReg("<img.*?\"(http.*?)\"","");
	
	public function new(?manga:String=null)
	{
		super(manga);
	}
	
	override public function getImageURL(chap:Int, page:Int):String
	{
		var url:String = mainURL + manga + "/c" + StringTools.lpad(""+chap,"0",3) + "/" + page + ".html";
		var request:Http = new Http(url);
		request.setHeader("User-Agent", "Mozilla/5.0");
		request.onStatus = function (i:Int)
			{
				if (i != 200)
				{
					throw "Http Error #404";
				}
			};
		request.request();
		
		var doc = request.responseData;
		
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
			return (getImageURL(chap, 1) != "");
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
		h.onStatus = function(e:Int) 
			{
				exist = (e == 200);
			};
		h.request(null);
		return exist;
	}
}
