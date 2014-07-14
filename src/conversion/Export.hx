package conversion;

import haxe.crypto.Crc32;
import haxe.zip.Entry;
import haxe.zip.Writer;

import utils.Utility;
import utils.TempFileName;

import wx.Bitmap;
import wx.Image;

import sys.FileSystem;
import sys.io.File;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class Export
{
	public static function toCBZ(manga:String, ?from:Int=1,?to:Int=10000, ?rotate:Bool=false)
	{
		var path = Main.mangaPath + manga;
		var epath = Main.exportPath + "/" + manga;
		FileSystem.createDirectory(epath);
		
		if (from > to)
			return;
		
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			var chapters = FileSystem.readDirectory(path);
			if (chapters.length == 0) {return ;}
			
			for (chap in chapters)
			{
				var cpath = path+"/"+chap;
				var cn = Std.parseInt(Utility.unLPad(chap));
				
				var entries:List<Entry> = new List();
				var zipName = epath+"/"+StringTools.lpad(manga+"_"+chap,"0",4)+".cbz";
				if (FileSystem.exists(zipName))
					continue;
				
				if (FileSystem.isDirectory(cpath) && cn >= from && cn <= to)
				{
					var images = FileSystem.readDirectory(cpath);
					if (images.length == 0)
						continue;
						
					for (img in images)
					{
						var pn = Std.parseInt(Utility.unLPad(img));
						if (!FileSystem.isDirectory(cpath+"/"+img) && pn != null)
						{
							var tmpPath = Sys.getCwd();
							
							while (FileSystem.exists(tmpPath))
								tmpPath = TempFileName.next();
								
							var f = Image.fromFile(cpath+"/"+img, wxBITMAP_TYPE_JPEG);
							if (rotate && (f.width > f.height))
								f.rotate(90);
							var bytes = f.getBytes(tmpPath);
							
							if (bytes == null || bytes.length == 0)
								continue;
							
							entries.add({
										fileName: StringTools.lpad(img,"0",3),
										fileSize: bytes.length,
										fileTime : Date.now(),
										compressed : false,
										dataSize : 0,
										data : bytes,
										crc32 : Crc32.make(bytes),
										extraFields : new List()
										});
						}
					}
					
					var zipFile	= File.write(zipName);
					var zipWriter = new Writer(zipFile);
					zipWriter.write(entries);
					zipFile.close();
				}
			} 
			
			return ;
		}
		
		return ;
	}
	
	public static function threadedToCBZ(manga:String, ?from:Int=1,?to:Int=10000, ?rotate:Bool=false,?onExit:Void->Void=null)
	{
		Thread.create(function()
			{
				toCBZ(manga,from,to,rotate);
				if (onExit != null)
					onExit();
			});
	}
}
