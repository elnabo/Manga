package utils;

#if cpp
import cpp.vm.Mutex;
#elseif neko
import neko.vm.Mutex;
#end


class TempFileName
{
	static var tmpFolder:String = (Sys.systemName() == "Windows") ? Sys.getEnv("TMP")+"\\" : "/tmp/";
	static var count:Int = 0;
	static var m:Mutex = new Mutex();
	
	public static function next():String
	{
		m.acquire();
		count++;
		m.release();
		return tmpFolder+"manga_"+count;
	}
}
