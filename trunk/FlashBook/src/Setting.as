package
{
	import flash.display.Bitmap;

	public class Setting
	{
		public static var swfLoaded:Boolean;
		
		public static var logo:Bitmap;
		
		private static var _basePath:String = "";
		
		public static function get basePath():String
		{
			return _basePath;
		}
		
		public static function set basePath(path:String):void
		{
			_basePath = path;
		}
		
		public static function getAbsPath(path:String):String
		{
			if(!path) return null;
			
			if(	path.indexOf("http:") == 0
				|| path.indexOf("https:") == 0
				|| path.indexOf("mailto:") == 0
				|| path.indexOf("file:") == 0
			)
			{
				return path;
			}
			else if(path.indexOf("/") == 0)
			{
				return basePath + path.substring(1);
			}
			else
			{
				return basePath + path;
			}
		}
	}
}