import db.Manga;
import plugin.*;
import uiwaxe.UIMain;
import web.Download;


import haxe.ds.ListSort;
import haxe.Http;
import sys.FileSystem;
import sys.db.Manager;
import sys.db.TableCreate;
import sys.db.Sqlite;

import wx.App;


class Main
{
	public static var db(default,never) = "manga.db";
	public static var mangaPath(default,never) = "manga/";
	public static var exportPath(default,never) = "export/";
	
	public static var plugins(default,null):Array<String> = [];
	public static var importPlugins(default,null):Array<String> = [];
	
	public function new()
	{
		if (initDB())
		{
			cleanDB();
			initPlugins();
			UIMain.onClose = close;
			new UIMain();
			
			checkMangaUpdate();
			restartDownload();
		}
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
			return false;
		}
	}
	
	private function cleanDB()
	{
		var mangas = Manga.all();
		for (m in mangas)
		{
			if (m.downloadStatus == 0 && m.lastChapterDownloaded == 0)
			{
				if (FileSystem.exists(m.name) && FileSystem.isDirectory(m.name))
				{
					if (FileSystem.readDirectory(m.name).length == 0)
					{
						FileSystem.deleteDirectory(m.name);
					}
				}
				m.delete();
			}
			
			if (m.downloadStatus == 1)
			{
				m.downloadStatus = 2;
				m.update();
			 }
		}
	}
	
	private function checkMangaUpdate()
	{
		var mangas = Lambda.array(Manga.all());
		for (m in mangas)
		{
			if (m.downloadStatus == 0 && m.pluginName != "None")
			{
				m.downloadPriority = Type.enumIndex(Priority.UPDATE);
				m.update();
				Download.threadedDownload(m.rawName, m.pluginName);
			}
		}
	}
	
	private function restartDownload()
	{
		var mangas = Lambda.array(Manga.all());
		mangas.sort(function (m1:Manga,m2:Manga)
			{
				if (m1.downloadPriority > m2.downloadPriority)
					return -1;
				if (m1.downloadPriority == m2.downloadPriority)
					return 0;
				return 1;
			});
		for (m in mangas)
		{
			if (m.downloadStatus == 2 && m.pluginName != "None")
			{
				
				Download.threadedDownload(m.rawName, m.pluginName);
			}
		}
	}
	
	private static function initPlugins()
	{
		CompileTime.importPackage("plugin");
		for ( cls in CompileTime.getAllClasses("plugin") )
		{
			var name = Type.getClassName(cls);
			if (name != "plugin.Plugin")
			{
				importPlugins.push(name);				
				var simpleName = name.split(".").pop();
				plugins.push(simpleName.substr(0, simpleName.length-6));
			}
		}
	}
	
	public static function close()
	{
		for (m in Manga.all())
		{
			if (m.downloadStatus == 1)
				m.downloadStatus = 2;
			m.update();
		}
		Manager.cleanup();
	}
	
	public static function main()
	{
		App.boot(function(){new Main();});
	}
}
