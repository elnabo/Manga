package db;

import sys.db.Manager;
import sys.db.Object;
import sys.db.Types;

@:id(id)
class Manga extends Object
{
	public var id:SId;
	public var name:SSmallText;
	public var lastChapterDownloaded:SSmallInt ;
	public var lastChapterRead:SSmallInt ;
	public var currentPageRead:SSmallInt ;
	public var currentChapterRead:SSmallInt ;
	
	public function new(name:String,?lastChapterDownloaded:Int=0)
	{
		super();
		this.name = name;
		this.lastChapterDownloaded = lastChapterDownloaded;
		lastChapterRead = 0;
		currentPageRead = 1;
		currentChapterRead = 1;
	}
	
	public static function get(manga:String):Manga
	{
		var query = manager.search($name == manga);
		if (query != null && query.length > 0)
			return query.first();
		return null;
	}
	public static var manager = new Manager<Manga>(Manga);
}
