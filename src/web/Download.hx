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

class Download
{
	private static var helper:Plugin = new MangaReaderPlugin();
	
	/** Return the string name of the file. */
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
	
	public static function download(manga:String)
	{
		manga = StringTools.trim(manga);
		if (manga == "") 
			return;
			
		var helper = Type.createInstance(Type.getClass(Download.helper), [manga]);
		if (!helper.exists())
			return;
		manga = manga.toLowerCase().split(" ").join("_");

		var db_value:Manga = null;
		for ( res in Manga.manager.search($name == manga))
		{
			db_value = res;
		}
		
		if (db_value == null)
		{
			db_value = new Manga(manga,helper.lastChapter);
			db_value.insert();
		}
		
		var count = 0;		
		var chap:Int = db_value.lastChapterDownloaded + 1;
		
		while (helper.doesChapterExists(chap))
		{
			var directory:String = manga+"/"+StringTools.lpad(""+chap,"0",4);
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
					}
					catch ( e : Dynamic )
					{
						trace(e,chap);
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
		
		db_value.update();
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
