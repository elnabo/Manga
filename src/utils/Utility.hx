package utils;

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
}
