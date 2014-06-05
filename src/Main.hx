import db.*;
import plugin.*;
import ui.UIMain;
import web.Download;


import haxe.Http;
import sys.FileSystem;
import sys.db.Manager;
import sys.db.TableCreate;
import sys.db.Sqlite;



class Main
{
	static var db = "manga.db";
	
	public function new()
	{
		initDB();
		new UIMain();
		return;
	}
	
	private static function initDB()
	{
		Manager.cnx = Sqlite.open(db);
		Manager.initialize();
		if (!TableCreate.exists(Manga.manager))
			TableCreate.create(Manga.manager);
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
	
	public static function main()
	{
		new Main();
	}
}
