package web;


import db.Manga;

import haxe.Http;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import sys.db.Manager;
import sys.io.File;
import sys.io.FileOutput;
import sys.FileSystem;

import plugin.*;

#if cpp
import cpp.vm.Deque;
import cpp.vm.Thread;
#elseif neko
import neko.vm.Deque;
import neko.vm.Thread;
#end

class Error
{
	//~ public static var tooManyActiveConnections(default,null):String = "Too many active connections";
	public static var invalidName(default,null):String = "Invalid manga name";
	public static var notAvailable(default,null):String = "This manga isn't available";
}

class Download
{
	private static var helper:Plugin = new MangaReaderPlugin();
	private static var activeConnections:Int = 0;
	private static var maxActiveConnections:Int = 2;
	private static var currentDownloads:Array<String> = new Array<String>();
	
	public static var onFinish(null,default):Manga->Void = function(_){};
	
	/* To do check integrity 
		Test if final size = original size
		*/
	/** Download the file. */
	public static function image(url:String, to:String, ?maxConnections:Int=2)
	{
		try
		{
			var f:FileOutput = File.write(to,true);
			var h:Http = new Http(url);
			
			
			// Test if server accept range request
			var length:Int = acceptRange(url);
			if( length != 0 && #if (neko || cpp) true #else false #end)
			{
				var start = 0;
				var end = 0;
				var sublength:Int = Std.int(length/maxConnections);
				var deque:Deque<PartialContent> = new Deque<PartialContent>();
				var range:Deque<Pair<Int,Int>> = new Deque<Pair<Int,Int>>();

				// Create the content range.
				for (i in 0...maxConnections)
				{
					end = ( i == maxConnections-1 ) ? length : end + sublength;
					range.push(new Pair<Int,Int>(start,end));
					start = end +1;
				}
				
				// Create the threads.
				for (i in 0...maxConnections)
				{
		
					var t = Thread.create(function()
					{
						var main:Thread = Thread.readMessage(true);
						var h:Http = new Http(url);
						var p:Pair<Int,Int> = range.pop(true);
						h.addHeader("Range","bytes="+p.k+"-"+p.v);
						h.request();
						var content:PartialContent = new PartialContent(Bytes.ofString(h.responseData),p.k,p.v);
						deque.push(content);
						main.sendMessage(true);
					});
					t.sendMessage(Thread.current());
					
				}
				
				// Wait until all thread are done.
				var count:Int = 0;
				while (count < maxConnections)
				{
					if (Thread.readMessage(true))
					{
						count ++;
					}
				}
				
				// Transform the deque to an array.
				var results = new Array<PartialContent>();
				while (true)
				{
					var pc:PartialContent = deque.pop(false);
					if (pc == null)
						break;
					results.push(pc);
				}
				
				// Put the part in the correct order.
				var bytes:Bytes = PartialContent.rebuild(results);
				f.writeBytes(bytes,0,bytes.length);
			}
			else
			{
				var bytes:Bytes = Bytes.ofString(Http.requestUrl(url));
				f.writeBytes(bytes,0,bytes.length);
			}
			
			f.flush();
			f.close();
		}
		catch (e:Dynamic)
		{
			throw e;
		}
	}
	
	/**
	 * Return content length if accept else 0 
	 */
	public static function acceptRange(url:String):Int
	{
		var h:Http = new Http(url);
		h.addHeader("Range","");
		h.customRequest(false,null,null,"HEAD");
		var headers = h.responseHeaders;
		if (headers.exists("Accept-Ranges") && headers.get("Accept-Ranges") != "none"
			&& headers.exists("Content-Length"))
			return Std.parseInt(headers.get("Content-Length"));
		return 0;
	}
	
	public static function test(manga:String)
	{
		manga = StringTools.trim(manga);
		if (manga == "") 
			throw Error.invalidName;
			
		var helper = Type.createInstance(Type.getClass(Download.helper), [manga]);
		if (!helper.exists())
			throw Error.notAvailable;
	}
	
	public static function download(manga:String, ?startChapter:Int=0)
	{
		manga = StringTools.trim(manga);
		if (manga == "") 
			return;
			
		
		var helper = Type.createInstance(Type.getClass(Download.helper), [manga]);

		if (!helper.exists())
			return;
		
		currentDownloads.push(manga);
			
		var db_manga = manga.toLowerCase().split(" ").join("_");
		var db_value:Manga = Manga.get(db_manga);
			
		if (db_value == null)
		{
			db_value = new Manga(db_manga, manga,helper.lastChapter);
			db_value.insert();
		}
		
		if (currentDownloads.indexOf(db_manga) == -1)
			return;
		
		if (activeConnections >= maxActiveConnections)
		{
			return;
		}
		
		db_value.downloadStatus = 1;
		
		var count = 0;		
		var chap:Int = Std.int(Math.max(startChapter,db_value.lastChapterDownloaded + 1));
		activeConnections++;
		
		var haveDownload = false;
		
		while (helper.doesChapterExists(chap))
		{
			var directory:String = db_manga+"/"+StringTools.lpad(""+chap,"0",4);
			FileSystem.createDirectory(directory);
			try
			{
				var page:Int = 1;
				var imgPath:String;
				while (true)
				{
					try
					{
						var imgURL = helper.getImageURL(chap,page);
						var imgType:String = imgURL.split(".").pop();
						imgPath = directory+"/"+StringTools.lpad(""+page,"0",3)+"."+imgType;
						Download.image(imgURL,imgPath);
						page++;
						haveDownload = true;
					}
					catch ( e : Dynamic )
					{
						break;
					}
				}
				chap++;
				count++;
				db_value.lastChapterDownloaded ++;
				
				if (count > 3)
				{
					count = 0;
					db_value.update();
				}
				
			}
			catch (e : Dynamic)
			{
				break;
			}
		}
		
		activeConnections--;
		
		currentDownloads.remove(db_manga);

		db_value.downloadStatus = 0;
		db_value.update();
		
		if (haveDownload)
			onFinish(db_value);
	}
	
	public static function threadedDownload(manga:String,?startChapter:Int=0,?onExit:Void->Void=null)
	{
		Thread.create(function()
			{
				download(manga,startChapter);
				if (onExit != null)
					onExit();
			});
	}
}


class Pair<K,V>
{
	public var k:K;
	public var v:V;
	
	public function new(k:K,v:V)
	{
		this.k = k;
		this.v = v;
	}
}
