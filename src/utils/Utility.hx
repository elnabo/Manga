package utils;

import sys.FileSystem;

class Utility
{
	public static function unLPad( s : String, p : String = "0" ) : String 
	{
		var l = s.length;
		var r = 0;
		while( r < l && s.charAt(r) == p )
		{
			r++;
		}
		if( r > 0 )
			return s.substr(r, l-r);
		else
			return s;
	}
	
	public static function deleteRecursive(path:String):Void
	{
		
		if (FileSystem.exists(path))
		{
			if (FileSystem.isDirectory(path))
			{
				for ( i in FileSystem.readDirectory(path))
				{
					deleteRecursive(path+"/"+i);
				}
				FileSystem.deleteDirectory(path);
			}
			
			else
			{
				FileSystem.deleteFile(path);
			}
		}
	}
}
