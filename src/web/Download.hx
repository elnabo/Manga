package web;

import haxe.Http;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import sys.io.File;
import sys.io.FileOutput;

#if cpp
import cpp.vm.Deque;
import cpp.vm.Thread;
#elseif neko
import neko.vm.Deque;
import neko.vm.Thread;
#end

class Download
{
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
			trace(e);
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
