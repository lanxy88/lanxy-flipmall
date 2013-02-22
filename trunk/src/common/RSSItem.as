package common
{
	/**
	 * 标准rss item 项
	 */
	public class RSSItem
	{
		
		
		public var title:String="";
		public var pubDate:String="";
		public var description:String="";
		public var link:String="";
		public var author:String="";
		
		
		public function RSSItem(title:String="",pubDate:String="",description:String="",link:String="",author:String="")
		{
			this.title = title;
			this.pubDate = pubDate;
			this.description = description;
			this.link = link;
			this.author = author;
		}
		
		public static function parse(xml:XML):RSSItem{
			var rssItem:RSSItem = new RSSItem();
			//if(String(xml.@title))  
				rssItem.title = String(xml.title);
			//if(String(xml.@pubDate)) 
				rssItem.pubDate = String(xml.pubDate);
			//if(String(xml.@description)) 
				rssItem.description = String(xml.description);
			//if(String(xml.@link)) 
				rssItem.link = String(xml.link);
			//if(String(xml.@author)) 
				rssItem.pubDate = String(xml.author);
			return rssItem;
		}
	}
}