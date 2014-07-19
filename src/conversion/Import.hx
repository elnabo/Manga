package conversion;

import db.Manga;
import utils.Utility;

import haxe.zip.Entry;
import haxe.zip.Reader;
import haxe.zip.Uncompress;

import sys.FileSystem;
import sys.io.File;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

typedef Chapter = 
	{
		name:String,
		chapter:Null<Int>
	}

class Import
{
	public static function fromCBZ(file:String, manga:String, chapter:Int)
	{
		if (manga == null || chapter < 1)
			return -1;
		
		var db_manga = manga.toLowerCase().split(" ").join("_");
		var db_entry = Manga.get(manga);
		if (db_entry == null)
		{
			db_entry = new Manga(manga,db_manga);
			FileSystem.createDirectory(Main.mangaPath + db_manga);
		}
		
		var path = Main.mangaPath + db_manga + "/" + StringTools.lpad(""+chapter,"0",4) + "/";
		FileSystem.createDirectory(path);
		for (entry in Reader.readZip(File.read(file)))
		{
			File.saveBytes(path+entry.fileName, entry.data);
		}
		return 0;
	}
	
	public static function threadedFromCBZ(file:String, manga:String, chapter:Int,?onExit:Dynamic->Void=null)
	{
		Thread.create(function()
			{
				if (onExit != null)
					onExit(fromCBZ(file,manga,chapter));
				else
					fromCBZ(file,manga,chapter);
			});
	}
	
	public static function extractInfoFromFile(file:String):Chapter
	{
		var f = file.toLowerCase();
		var noCbz = f.substring(0,f.lastIndexOf(".cbz"));
		
		// Do not contain manga name & chapter
		if (noCbz.indexOf("_") == -1)
		{
			var chapter = Std.parseInt(Utility.unLPad(noCbz));
			if (chapter != null)
				return {name:null,chapter:chapter};
				
			// Suppose that the file name is the manga name 
			var manga = Manga.get(noCbz);
			return {name:(manga!=null) ? manga.rawName : noCbz
					,chapter:null};
		}
		
		var infos = noCbz.split("_");
		if (infos.length != 2)
			return null;
			
		var manga = Manga.get(infos[0]);
		return {name : (manga != null) ? manga.rawName : infos[0], 
				chapter : Std.parseInt(Utility.unLPad(infos[1]))};
		
	}
}
