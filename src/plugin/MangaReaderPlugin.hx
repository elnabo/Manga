package plugin;

import haxe.Http;

class MangaReaderPlugin extends Plugin
{
	public static var mainURL(default,null):String = "http://www.mangareader.net/";
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
			var doc:String = Http.requestUrl(mainURL+manga+"/"+(chap+1)+"/2");
			return (doc.indexOf("<h1>404 Not Found</h1>",doc.length-25) == -1);
		}
		catch ( _ : Dynamic)
		{
			return false;
		}
	}
}
