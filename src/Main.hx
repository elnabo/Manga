import db.*;
import plugin.*;
//~ import ui.UIMain;
import uiwaxe.UIMain;
import web.Download;


import haxe.Http;
import sys.FileSystem;
import sys.db.Manager;
import sys.db.TableCreate;
import sys.db.Sqlite;

import wx.App;


//~ import lime.Lime;

class Main
{
	static var db = "manga.db";
	
	public function new()
	{
		initDB();
		//~ if (initDB())
		new UIMain();
		return;
	}
	
	private function initDB()
	{
		try
		{
			Manager.cnx = Sqlite.open(db);
			Manager.initialize();
			if (!TableCreate.exists(Manga.manager))
				TableCreate.create(Manga.manager);
			return true;
		}
		catch ( e : Dynamic ) 
		{
			//~ var config = {
			//~ host : this,
			//~ fullscreen : false,
			//~ resizable : false,
			//~ borderless : false,
			//~ antialiasing : 0,
			//~ stencil_buffer : false,
			//~ depth_buffer : false,
			//~ vsync : false,
			//~ multitouch_supported : false,
			//~ multitouch : false,
			//~ fps : 10,
			//~ width : 100,
			//~ height : 100,
			//~ title : "Error"
			//~ };
			//~ var lime = new Lime();
			//~ lime.init(this,config);
			
			return false;
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
	
	public static function main()
	{
		App.boot(function(){new Main();});
	}
}
