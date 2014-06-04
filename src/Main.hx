import plugin.MangaReaderPlugin;
import ui.UIMain;
import web.Download;


import haxe.Http;
import sys.FileSystem;
import sys.db.Sqlite;



class Main
{
	public function new()
	{
		//~ var url:String = "http://www.mangareader.net/billy-bat/1/1";
		new UIMain();
		var url:String = "http://www.mangareader.net/";
		var manga:String = "phantom-brave-ivoire-monogatari";
		Sqlite.open("test.db");
		
		var helper = new MangaReaderPlugin("phantom-brave-ivoire-monogatari");
		
		
		return;
		var chap:Int = 1;
		while (helper.doesChapterExists(chap))
		{
			var directory:String = manga+"/"+StringTools.lpad(""+chap,"0",4);
			FileSystem.createDirectory(directory);
			try
			{
				var page:Int = 1;
				var imgPath:String;
				while (true)
				{
					try
					{
						//~ var imgURL:String = getImage(url+manga+"/"+chap+"/"+page, imgRegex);
						var imgURL = helper.getImageURL(chap,page);
						var imgType:String = imgURL.split(".").pop();
						imgPath = directory+"/"+StringTools.lpad(""+page,"0",3)+"."+imgType;
						Download.image(imgURL,imgPath);
						page++;
					}
					catch ( e : Dynamic )
					{
						break;
					}
				}
				chap++;
			}
			catch (e : Dynamic)
			{
				//~ try
				//~ {
					//~ FileSystem.removeFile(imgPath);
				//~ }
				//~ catch ( _ : Dynamic) {}
				break;
			}
		}
	}
	
	public function chapterExists(url:String,manga:String,chap:Int):Bool
	{
		try
		{
			var doc:String = Http.requestUrl(url+manga+"/"+(chap+1)+"/2");
			return (doc.indexOf("<h1>404 Not Found</h1>",doc.length-25) == -1);
		}
		catch ( _ : Dynamic)
		{
			return false;
		}
	}
	
	public function getImage(url:String, imgRegex:EReg):String
	{
		var doc:String = Http.requestUrl(url);
		if (doc.indexOf("<h1>404 Not Found</h1>",doc.length-25) != -1)
			throw "http 404";
		imgRegex.match(doc);
		return imgRegex.matched(1);
	}
	
	public static function main()
	{
		new Main();
	}
}
