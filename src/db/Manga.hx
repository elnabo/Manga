package db;

import utils.Utility;

import sys.FileSystem;
import sys.db.Manager;
import sys.db.Object;
import sys.db.Types;

#if cpp
import cpp.vm.Mutex;
#elseif neko
import neko.vm.Mutex;
#end

enum Priority
{
	LOW;
	NORMAL;
	HIGH;
	PREUPDATE;
	UPDATE;
}

@:id(id)
class Manga extends Object
{
	public var id:SId;
	public var name:SSmallText;
	public var rawName:SSmallText;
	public var lastChapterDownloaded:SSmallInt;
	public var lastChapterRead:SSmallInt;
	public var currentPageRead:SSmallInt;
	public var currentChapterRead:SSmallInt;
	public var downloadStatus:SSmallInt;
	public var downloadPriority:SSmallInt;
	public var recentDownload:SSmallInt;
	public var pluginName:SSmallText;
	
	private static var m:Mutex = new Mutex();
	
	public function new(name:String,rawName:String,?lastChapterDownloaded:Int=0, ?plugin:String="None")
	{
		super();
		this.name = name;
		this.rawName = rawName;
		this.lastChapterDownloaded = lastChapterDownloaded;
		lastChapterRead = 0;
		currentPageRead = 1;
		currentChapterRead = 1;
		downloadStatus = 2;
		downloadPriority = Type.enumIndex(Priority.NORMAL);
		recentDownload = 1;
		pluginName = plugin;
	}
	
	override public function update()
	{
		m.acquire();
		super.update();
		m.release();
	}
	override public function insert()
	{
		m.acquire();
		super.insert();
		m.release();
	}
	
	public static function all():List<Manga>
	{
		m.acquire();
		var l = manager.all();
		m.release();
		return l;	
	}
	
	public static function get(manga:String):Manga
	{
		m.acquire();
		var query = manager.search($name == manga);
		m.release();
		if (query != null && query.length > 0)
			return query.first();
		return null;
	}
	
	public static function getFromRaw(manga:String):Manga
	{
		m.acquire();
		var query = manager.search($rawName == manga);
		m.release();
		if (query != null && query.length > 0)
			return query.first();
		return null;
	}
	
	public static function findSimilar(manga:String):Manga
	{
		var lc = manga.toLowerCase().split(" ").join("_");
		return get(lc);
	}
	
	public function getChapterList():Array<String>
	{
		var path = Main.mangaPath+name+"/";
		return Lambda.array(Lambda.filter(
			FileSystem.readDirectory(path),
			function (e) 
			{
				return FileSystem.isDirectory(path+e);
			}
			));
	}
	
	public function chapterExists(chapter:Int)
	{
		var path = Main.mangaPath+name+"/"+StringTools.lpad(""+chapter,"0",4);
		return FileSystem.exists(path) && FileSystem.isDirectory(path);
	}
	
	public static var manager = new Manager<Manga>(Manga);
}
