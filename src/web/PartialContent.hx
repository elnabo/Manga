package web;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

class PartialContent
{
	public var start(default,null):Int;
	public var end(default,null):Int;
	public var content(default,null):Bytes;
	
	public function new(content:Bytes,start:Int,end:Int)
	{
		this.content = content;
		this.start = start;
		this.end = end;
	}
	
	public static function rebuild(contents:Array<PartialContent>) : Bytes
	{
		contents.sort(compare);
		var buffer:BytesBuffer = new BytesBuffer();
		for (pc in contents)
		{
			buffer.add(pc.content);
		}
		return buffer.getBytes();
	}
	
	public static function compare(a:PartialContent,b:PartialContent) : Int
	{
		if (a.start < b.start)
			return -1;
		if (a.start == b.start)
			return 0;
		return 1;
	}
	
}
