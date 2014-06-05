package plugin;

import haxe.Http;

class MangaDoomPlugin extends Plugin
{
	public static var mainURL(default,null):String = "http://mangadoom.com/";
	private static var imgRegex:EReg;
	
	private var regex:String;
	
	@override private inline function set_manga(value:String) {_manga = value; findLastChapterLocal(); imgRegex = new EReg("<img id.*?\"(http.*?)\".*?.*?wpm_nav_nxt = \"http://mangadoom.com/"+manga+"/([0-9]+)/","is"); return _manga;}
	
	
	public function new(?manga:String=null)
	{
		super(manga);
		if (manga != null)
			imgRegex = new EReg("<img id.*?\"(http.*?)\".*?.*?wpm_nav_nxt = \"http://mangadoom.com/"+manga+"/([0-9]+)/","is");
	}
	
	
	
	override public function getImageURL(chap:Int, page:Int):String
	{
		var url:String = mainURL + manga + "/" + chap + "/" + page;
		var doc:String = Http.requestUrl(url);
		if (doc.indexOf("is not available yet!") != -1)
			throw "no image";
			
		imgRegex.match(doc);
		//~ if (imgRegex.matched(2) == ""+chap) last pictures
		//~ {
		var res = imgRegex.matched(1);
		var lio = res.lastIndexOf("?");
		if (lio == -1)
			return res;
		return res.substring(0,lio);
		//~ }
		//~ throw "no image";
	}
	
	override public function doesChapterExists(chap:Int):Bool
	{
		try
		{
			var doc:String = Http.requestUrl(mainURL+manga+"/"+(chap));
			return (doc.indexOf("is not available yet!") == -1);
		}
		catch ( _ : Dynamic)
		{
			return false;
		}
	}
}
