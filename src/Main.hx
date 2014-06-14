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

class Main
{
	static var db = "manga.db";
	
	public function new()
	{
		initDB();
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
			trace(e);
			return false;
		}
	}
	
	public static function main()
	{
		App.boot(function(){new Main();});
	}
}
