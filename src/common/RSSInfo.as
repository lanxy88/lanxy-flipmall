package common
{
	import controls.RSSBox;

	/**
	 * rss 配置信息
	 */
	public class RSSInfo
	{
		public var page:int = 0;
		public var url:String = "";
		public var x:int = 0;
		public var y:int = 0;
		public var width:int = 100;
		public var height:int = 20;
		
		public var rssBox:RSSBox=null;
		
		public function RSSInfo(page:int = 0, url:String="", x:int = 0,y:int =0,width:int = 100, height:int =300)
		{
			this.page = page;
			this.url = url;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}

		public static function parse(xml:XML):RSSInfo{
			var item:RSSInfo = new RSSInfo();
			if(String(xml.@page)) item.page = int(xml.@page);
			if(String(xml.@url)) item.url = String(xml.@url);
			if(xml.@x) item.x = int(xml.@x);
			if(xml.@y) item.y = int(xml.@y);
			if(xml.@width) item.width = int(xml.@width);
			if(xml.@height) item.height = int(xml.@height);
			return item;
		}
	}
}