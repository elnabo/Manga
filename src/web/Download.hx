package web;


import db.Manga;

import haxe.Http;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
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
	
	public static var onFinish(null,default):Manga->Bool->Void = function(_,_){};
	
	/* To do check integrity 
		Test if final size = original size
		*/
	/** 
	 * Download the file. 
	 * Return true on success, false on failure
	 */
	public static function image(url:String, to:String, ?maxConnections:Int=2)
	{
		try
		{
			var h:Http = new Http(url);
			
			
			// Test if server accept range request
			var res:Pair<Bool,Int> = acceptRange(url);
			var length:Int = res.v;
			var bytes:Bytes;
			
			if( res.k && #if (neko || cpp) true #else false #end)
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
				bytes = PartialContent.rebuild(results);
			}
			else
			{
				bytes = Bytes.ofString(Http.requestUrl(url));
			}
			
			if (bytes.length != length)
				return false;
				
			var f:FileOutput = File.write(to,true);
			f.writeBytes(bytes,0,bytes.length);
			f.flush();
			f.close();
		}
		catch (e:Dynamic)
		{
			throw e;
		}
		return true;
	}
	
	/**
	 * Return content length if accept else 0 
	 */
	public static function acceptRange(url:String)
	{
		var h:Http = new Http(url);
		h.addHeader("Range","");
		h.customRequest(false,null,null,"HEAD");
		var headers = h.responseHeaders;
		var res= (headers.exists("Accept-Ranges") && headers.get("Accept-Ranges") != "none"
			&& headers.exists("Content-Length"));
			
		return new Pair<Bool,Int>(res, Std.parseInt(headers.get("Content-Length")));
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
			
		var db_manga = manga.toLowerCase().split(" ").join("_");
		var db_value:Manga = Manga.get(db_manga);
			
		if (db_value == null)
		{
			db_value = new Manga(db_manga, manga,helper.lastChapter);
			db_value.insert();
		}
		
		//~ trace(db_value.name, db_value.downloadStatus, db_value.downloadPriority);
		
		if (currentDownloads.indexOf(manga) != -1)
			return;
			
		db_value.downloadStatus = 2;
		
		if (activeConnections >= maxActiveConnections)
		{
			return;
		}
		
		currentDownloads.push(manga);
		
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
						while (true)
						{
							if (Download.image(imgURL,imgPath))
								break;
						}
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
		currentDownloads.remove(manga);

		db_value.downloadStatus = 0;
		db_value.update();
		
		onFinish(db_value,haveDownload);
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
